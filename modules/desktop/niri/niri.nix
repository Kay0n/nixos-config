{ inputs, homeManager, ... }:
{
  flake-file.inputs.multiverse.url = "github:fzakaria/nixpkgs-multiverse";

  flake.modules.nixos.niri = { pkgs, ... }: {

    imports = [
      inputs.multiverse.nixosModules.default
    ];


    programs.niri = {
      enable = true;
      useNautilus = true;
    };


    home-manager.sharedModules = [ homeManager.niri ];

    multiverse.enable = true;
    multiverse.pins.xwayland-satellite = "0.8.1";


    services.keyd = {
      enable = true;

      keyboards.default = {
        settings = {
          global = {
            overload_tap_timeout = 200;
          };
          main = {
            # sends mod+g on release
            leftmeta = "overload(meta, M-g)";
            capslock = "f9";
          };
        };
      };
    };


    environment.systemPackages = with pkgs; [
      # === DE substitutes === #
      xdg-desktop-portal-gnome
      # xwayland-satellite
      udiskie # auto mount external drives - needs udisks2 sservice
      # === Programs === #
      nautilus # file manager
      loupe # image viewer
      mission-center # task mgr
      gnome-text-editor
      gnome-disk-utility
      file-roller # file extraction
      vlc # media player
    ];

    services.udisks2.enable = true;

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
    };


    security.polkit.enable = true;


    environment.sessionVariables.NIXOS_OZONE_WL = "1"; 


  };

  flake.modules.homeManager.niri = { pkgs, config, ... }: {

    xdg.configFile."niri/config.kdl".source = config.lib.dotfiles.link ./config.kdl;

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 11;
      };
      gtk4.theme = null;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/interface" = {
        gtk-theme = "adw-gtk3";
      };

    };
    # home.sessionVariables.GTK_THEME = "adw-gtk3";
  };
}
