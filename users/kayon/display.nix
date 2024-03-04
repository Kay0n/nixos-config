
{ config, pkgs, lib, ... }:

{

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style.name = "adwaita-dark";
  };

  home.packages = with pkgs; [
    discord
    vscode
    steam
    calibre
    prismlauncher
    protonup-qt
    qbittorrent
    lutris
    wineWowPackages.stable
    nil
  ];

  dconf.settings = { 

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
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
      command = "gnome-system-monitor";
      name = "System Moniter";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>m";
      command = "code";
      name = "VSCode";
    };
  };

}