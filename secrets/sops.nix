{ ... }:
{
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/home/kayon/.ssh/id_ed25519" ];
  sops.secrets = {
    copyparty_pass = { 
      owner = "kayon";
    };
    rclone_client_id = { };
    rclone_client_secret = { };
    rclone_access_token = { };
    rclone_crypt_book_pass = { };
    rclone_crypt_immich_pass = { };
    hardcover_api_key = { }; # token expires 22/11/2026
    homepage_env = {
      sopsFile = ./homepage.env;
      format = "dotenv";
    };

    immich_api_key = { };
    calibre_web_automated_kayon_password = { };
  };
  environment.variables = {
    SOPS_AGE_KEY_FILE = "/home/kayon/.ssh/id_ed25519";
  };
}