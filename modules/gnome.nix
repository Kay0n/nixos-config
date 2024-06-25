
{ pkgs, ... }: {

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.core-utilities.enable = false;

  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome.gnome-music nixos-render-docs pantheon.epiphany ];
  services.xserver.excludePackages = with  pkgs; [ xterm ];

  environment.systemPackages = with pkgs; [
    gnome.file-roller # archive manager
    gnome.nautilus # file manager
    kgx # console
    gnome-text-editor
    gnome.gnome-system-monitor
    gnome.gnome-disk-utility
    loupe
  ];

}
