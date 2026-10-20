{ ... }:
{
  # SSO portal at login.refract.online
  flake.modules.nixos.authelia = { config, ... }: let secrets = config.sops.secrets; in {

    # module passes these in via systemd LoadCredential, so root ownership is fine
    sops.secrets = {
      authelia_jwt_secret = { };
      authelia_session_secret = { };
      authelia_storage_key = { };
      authelia_users = {
        owner = "authelia-main";
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
          inactivity = "1d";
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
          # new subdomains are private until listed here
          default_policy = "deny";
          rules = [
            { domain = "login.refract.online"; policy = "bypass"; }
            { domain = [ "refract.online" "rdp.refract.online" ]; policy = "two_factor"; }
            { domain = [ "files.refract.online" "books.refract.online" ]; policy = "one_factor"; }
          ];
        };
      };
    };

  };
}
