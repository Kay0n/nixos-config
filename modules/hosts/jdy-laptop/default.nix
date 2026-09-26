{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  # see also ./nvidia.nix
  flake.modules.nixos."hosts/jdy-laptop" =
    { pkgs, lib, ... }:
    {

      imports = with nixos; [
        ./_hardware-configuration.nix

        base
        kayon
        pipewire
        # gnome
        niri
        # java
        syncthing
        firefox
      ];


      # user specific settings   
      home-manager.users.kayon = {
        imports = with homeManager; [
          vscode
          scripts
        ];

        home.packages = with pkgs; [
          vesktop # discord client
          onlyoffice-desktopeditors
          nil # nix language server
          obsidian

        ];
      };

      environment.systemPackages = with pkgs; [
      ];

      services.logind.lidSwitch = "lock";

      programs.zsh.enable = true;

      # systemd.extraConfig = ''
      #   DefaultTimeoutStopSec=3s
      # '';
      # systemd.user.extraConfig = ''
      #   DefaultTimeoutStopSec=3s
      # '';

      # # Used to setup aarch64 oracle with nixos-anywhere  
      # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

      networking.hostName = "jdy-laptop"; 


    };
}
