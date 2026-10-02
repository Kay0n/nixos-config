{ inputs, ... }:
{
  flake-file.inputs.millennium = {
    url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.steam = { pkgs, ... }: {
    nixpkgs.overlays = [ inputs.millennium.overlays.default ];

    programs.steam = {
      enable = true;
      package = pkgs.millennium-steam;
    };
  };
}
