

{ config, pkgs, ... }:

{

  # # Used to setup aarch64 oracle with nixos-anywhere  
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "jdy-laptop"; 
 
  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Adelaide";

  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.core-utilities.enable = false;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
  

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = { 

          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
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
    ];
  };


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
    # vlc
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
  
  
  system.stateVersion = "23.11"; 
  

}
