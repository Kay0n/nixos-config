{ inputs, lib, ... }:
{
  # Every .nix file under ./modules is a flake-parts module, auto-imported by import-tree
  # (paths containing `/_` are skipped - used for plain NixOS modules like hardware configs).
  #
  # Features register themselves as `flake.modules.nixos.<name>` / `flake.modules.homeManager.<name>`
  # and declare the flake inputs they need via `flake-file.inputs`.
  #
  # flake.nix is GENERATED from these modules. After changing any `flake-file.*` option run:
  #   `nix run .#write-flake`
  # then `nix flake lock` to lock any new inputs.

  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];

  flake-file.description = "Kayon's NixOS Root Flake";

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  systems = [ "x86_64-linux" ];
}
