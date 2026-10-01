{ inputs, homeManager, ... }:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    # provides `config.lib.dotfiles.link`, see modules/flake/dotfiles.nix
    home-manager.sharedModules = [ homeManager.dotfiles ];

    home-manager.backupFileExtension = "backup"; # needed?

  };
}
