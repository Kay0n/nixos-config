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
    rclone_crypt_password = { };
    hardcover_api_key = { }; # token expires 22/11/2026
  };
}