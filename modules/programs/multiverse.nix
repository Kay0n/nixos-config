{ inputs, ... }:
{
  flake-file.inputs.multiverse.url = "github:fzakaria/nixpkgs-multiverse";

  flake.modules.nixos.multiverse = { pkgs, ... }: {

    imports = [
      inputs.multiverse.nixosModules.default
    ];

    multiverse = {
      enable = true;
      pins = {
        # "godot" = "4.6.3-stable";
      };
    };
    # multiverse.pins.<pkgname> = "0.8.1";

    environment.systemPackages = with pkgs; [
    ];

  };


  
}
