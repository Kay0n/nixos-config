{ pkgs, inputs, config, ... }:
{


  programs.niri = {
    enable = true;
    useNautilus = true;
  };


  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = "kayon";
    };
    defaultSession = "niri";
  };


  home-manager.users.kayon = {config, ...}: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;
      settings = "/home/kayon/.nixos-config/modules/niri/noctalia-config";
    };

    xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "/home/kayon/.nixos-config/modules/niri/config.kdl";

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
    };

    dconf.settings = { 
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/interface" = {
        gtk-theme = "adw-gtk3";
      };

    };

    home.sessionVariables.GTK_THEME = "adw-gtk3";

  };


  








  

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
        };
      };
    };
  };

  
  environment.systemPackages = with pkgs; [

    # niri

    # === DE substitutes === #
    xdg-desktop-portal-gnome 
    xwayland-satellite

    udiskie # auto mount external drives - needs udisks2 sservice


    # === Programs === #
    alacritty # terminal TODO: need? defined in hm
    nautilus # file manager
    loupe # image viewer
    mission-center # task mgr
    gnome-text-editor
    gnome-disk-utility 
    file-roller # file extraction

    # === theming programs === #
    pywalfox-native # firefox theming




  ];






  services.udisks2.enable = true;




  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];


  # security.pam.services.hyprlock = {};
  security.polkit.enable = true;


  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # make xwayland use 


}
