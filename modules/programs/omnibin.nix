{ inputs, ... }:
{
  flake-file.inputs.omnibin = {
    url = "github:fzakaria/omnibin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.omnibin = { 
    imports = [ inputs.omnibin.nixosModules.default];
    services.omnibin.enable = false;
  };
}