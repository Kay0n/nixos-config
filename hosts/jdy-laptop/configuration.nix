

{ config, pkgs, ... }:

{

  # # Used to setup aarch64 oracle with nixos-anywhere  
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "jdy-laptop"; 
 
  networking.networkmanager.enable = true;

  

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

  

  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;

  };

  

  security.sudo.extraRules = [
    {
      users = [ "kayon" ];
      commands = [
        {
          command = "ALL";
          options = [ "SETENV" "NOPASSWD" ];
        }
      ];
    }
  ]; 

  users.users.kayon = {
    isNormalUser = true;
    description = "Kayon";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };


  programs.zsh.enable = true;


  environment.pathsToLink = [ "/share/zsh" ];
 
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    home-manager
    gnome.file-roller
    firefox
    wget
    gnome.nautilus
    kgx
    gnome-text-editor
    gnome.gnome-system-monitor
    home-manager
    winetricks
    vlc
    git
    python3
    tmux
    temurin-jre-bin-17
    zsh
  ];





  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not nouveau)
    open = false;

    # Enable the Nvidia settings menu (program nvidia-settings)
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };


}
