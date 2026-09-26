{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.nixos.gnome =
    { pkgs, ... }: {


      services.xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "";
        };
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        excludePackages = with  pkgs; [ xterm ];
      };


      services.gnome.core-utilities.enable = false;

      home-manager.sharedModules = [ homeManager.gnome ];

      environment.gnome.excludePackages = with pkgs; [ 
        gnome-tour 
        gnome-music 
        nixos-render-docs 
        pantheon.epiphany 
      ];

      environment.systemPackages = with pkgs; [
        file-roller # archive manager
        nautilus # file manager  services.xserver.
        kgx # console
        alacritty # alt console
        gnome-text-editor
        gnome-tweaks
        gnome-disk-utility
        loupe
        gnomeExtensions.paperwm
        gnomeExtensions.forge
        gnomeExtensions.pop-shell
      ];

    };


  flake.modules.homeManager.gnome =
    { pkgs, lib, ... }: {

      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "adwaita";
        # style.name = "adwaita-dark";
      };

      home.packages = with pkgs; [
        gnomeExtensions.steal-my-focus-window
        gnomeExtensions.tray-icons-reloaded
      ];



      dconf.settings = { 

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };

        "org/gnome/mutter" = {
          experimental-features = ["scale-monitor-framebuffer"];
        };

        "org/gnome/shell/keybindings" = {
          show-screenshot-ui = ["<Shift><Super>s"];
        };

        "org/gnome/desktop/wm/keybindings" = {
          toggle-fullscreen = [ "<Super>r" ];
          close = [ "<Super>q" ];
          show-desktop = [ "<Super>d" ];
          switch-windows = ["<Alt>Tab"];
          switch-windows-backward = ["<Shift><Alt>Tab"];
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          ];
          home = [ "<Super>e" ];
          control-center = [ "<Super>i" ];
          www = [ "<Super>f" ];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>t";
          command = "kgx";
          name = "GNOME Console";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Shift><Control>Escape";
          command = "${pkgs.mission-center}/bin/missioncenter";
          name = "Mission Center";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          binding = "<Super>m";
          command = "code";
          name = "VSCode";
        };
      };

    };
}
