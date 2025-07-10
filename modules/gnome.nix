
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

}
