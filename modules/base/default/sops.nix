{ inputs, root, ... }:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # see secrets/.sops.yaml for key management
  flake.modules.nixos.sops = {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.defaultSopsFile = root + "/secrets/secrets.yaml";
    sops.age.sshKeyPaths = [ "/home/kayon/.ssh/id_ed25519" ];
    sops.secrets = {
      copyparty_pass = { 
        owner = "kayon";
      };
      hardcover_api_key = { }; # token expires 22/11/2026
      homepage_env = {
        sopsFile = root + "/secrets/homepage.env";
        format = "dotenv";
      };

      immich_api_key = { };
      calibre_web_automated_kayon_password = { };
    };
    environment.variables = {
      SOPS_AGE_KEY_FILE = "/home/kayon/.ssh/id_ed25519";
    };
  };
}
