{ ... }:
{
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/home/kayon/.ssh/id_ed25519" ];
  sops.secrets = {
    copyparty_pass = { 
      owner = "kayon";
    };
  };
}