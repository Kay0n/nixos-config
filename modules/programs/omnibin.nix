{ inputs, ... }:
{
  flake-file.inputs.omnibin = {
    url = "github:fzakaria/omnibin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # provides omnibin-shell with every binary on PATH 
  # the nixos module is mean for VMs/containers, not workstations
  flake.modules.nixos.omnibin = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.omnibin.packages.${pkgs.stdenv.hostPlatform.system}.omnibin-shell
    ];
  };
}
