{ config, lib, pkgs, ... }:

let
  ow-mod-man-src = builtins.fetchGit {
    url = "https://github.com/ow-mods/ow-mod-man.git";
    ref = "main";
  };

  overlay = import "${ow-mod-man-src}/overlays/default.nix";
in {
  nixpkgs.overlays = [ overlay ];

  environment.systemPackages = with pkgs; [
    (import ow-mod-man-src {}).packages.${pkgs.system}.owmods-gui
  ];
}
