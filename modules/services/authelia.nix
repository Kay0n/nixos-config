{ root, ... }:
{
  # SSO portal at login.refract.online
  flake.modules.nixos.authelia = { config, ... }: let
    secrets = config.sops.secrets;
    sopsFile = root + "/secrets/authelia.yaml";
  in {

    sops.secrets = {
      authelia_jwt_secret = { inherit sopsFile; };
      authelia_session_secret = { inherit sopsFile; };
      authelia_storage_key = { inherit sopsFile; };
      authelia_users = {
        inherit sopsFile;
        owner = "authelia-main";
        restartUnits = [ "authelia-main.service" ];
      };
    };

    services.authelia.instances.main = {
      enable = true;

      secrets = {
        jwtSecretFile = secrets.authelia_jwt_secret.path;
        sessionSecretFile = secrets.authelia_session_secret.path;
        storageEncryptionKeyFile = secrets.authelia_storage_key.path;
      };

      settings = {
        theme = "dark";
        default_2fa_method = "totp";

        server.address = "tcp://127.0.0.1:9091";

        log = {
          level = "info";
          format = "text";
        };

        session = {
          inactivity = "6h";
          expiration = "1w";
          remember_me = "1M";
          cookies = [
            {
              domain = "refract.online";
              authelia_url = "https://login.refract.online";
              default_redirection_url = "https://refract.online";
            }
          ];
        };

        authentication_backend = {
          password_reset.disable = true;
          password_change.disable = true;
          file = {
            path = secrets.authelia_users.path;
            watch = false;
          };
        };

        storage.local.path = "/var/lib/authelia-main/db.sqlite3";

        # no smtp, 2FA registration links get written here
        notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";

        totp.issuer = "refract.online";

        access_control = {
          # first matching rule wins
          # caddy block must import an authelia snippet 
          default_policy = "deny";
          rules = [
            { domain = "login.refract.online"; policy = "bypass"; }

            # admins: everything, 2fa unless listed
            { domain = [ "files.refract.online" "books.refract.online" ]; subject = "group:admins"; policy = "one_factor"; }
            { domain = [ "refract.online" "*.refract.online" ]; subject = "group:admins"; policy = "two_factor"; }

            # other users: only what's listed
            { domain = "celeste.refract.online"; subject = "group:celeste"; policy = "one_factor"; }

            # any logged in user, cwa decides what they see (public view if no account)
            { domain = "books.refract.online"; policy = "one_factor"; }

            # everyone else
            { domain = [ "refract.online" "*.refract.online" ]; policy = "deny"; }
          ];
        };
      };
    };

  };
}
