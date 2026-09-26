{ inputs, ... }:
{
  # second nixpkgs that can be pinned independently, exposed as `pkgs.temp.<pkg>`
  flake-file.inputs.nixpkgs-temp.url = "github:nixos/nixpkgs/nixos-unstable";

  flake.modules.nixos.nixpkgs-temp = {
    nixpkgs.overlays = [
      (final: prev: {
        temp = import inputs.nixpkgs-temp {
          inherit (final) config;
          inherit (final.stdenv.hostPlatform) system;
        };
      })
    ];
  };
}
