{ pkgs, inputs, ... }:
{

  nixpkgs.overlays = [
    # inputs.hyprpanel.overlay
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  hardware.bluetooth = {
    enable = true;
    # powerOnBoot = true;
    # settings = {
    #   General = {
    #     Experimental = true;
    #   };
    # };
  };

  services.gvfs.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = "kayon";
    };
    defaultSession = "hyprland-uwsm";
    
  };

  # grimblast screenshots go in correct dir
  environment.variables = {
    XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";
  };


  home-manager.users.kayon = {
    programs.alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.90;
        colors.primary = {
          background = "#181824";
          # foreground = "#9fa5c9";
        };
      };
    };
  };


  environment.systemPackages = with pkgs; [

    # === DE substitutes === #
    xdg-desktop-portal-hyprland # general DE stuff (file picker, screen sharing)
    xdg-desktop-portal-gtk # TODO: do I need?
    hyprpolkitagent # auth daemon
    # wofi # launcher
    walker
    hyprlock # TODO: need? activated in security
    hypridle # idle
    hyprpanel
    clipman # clipse # clipboard
    wl-clipboard
    xorg.xrdb # proper xwayland scaling - see ~/.Xresources
    grimblast # screenshots
    # kdePackages.xwaylandvideobridge # run on start, discord screen share
    udiskie # auto mount external drives


    # === Programs === #
    alacritty # terminal TODO: need? defined in hm
    nautilus # file manager
    loupe # image viewer
    mission-center
    gnome-text-editor
    gnome-disk-utility
    file-roller # file extraction

    udiskie # automounter frontend - mneeds udisks2 sservice
    # blueman TODO: work?
  ];


  services.udisks2.enable = true;




  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];


  # hyprlock for login
  security.pam.services.hyprlock = {};
  security.polkit.enable = true;


  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # make xwayland use 


  # home-manager.users.kayon = {
  #   wayland.windowManager.hyprland = {
  #     enable = true;
  #     package = null;
  #     portalPackage = null;
  #     settings = {

  #     };
  #   };
  # }
}
