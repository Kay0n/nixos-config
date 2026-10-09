{ inputs, ... }:
{
  flake-file.inputs.multiverse.url = "github:fzakaria/nixpkgs-multiverse";

  flake.modules.nixos.multiverse = { ... }: {

    imports = [
      inputs.multiverse.nixosModules.default
    ];

    multiverse.enable = true;

    # multiverse.pins.<pkgname> = "0.8.1";

  };
  
}
