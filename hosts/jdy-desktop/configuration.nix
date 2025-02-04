{ pkgs, lib, ... }: 

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  imports = [
    ../../modules/common.nix
    ../../users/kayon/system-load.nix
    ../../modules/pipewire.nix
    ../../modules/gnome.nix
    ../../modules/java.nix
    # ../../modules/dotnet.nix
    
  ];
  

  # user specific settings   
  home-manager.users.kayon = {
    imports = [
      ../../users/kayon
      ../../users/kayon/modules/vscode.nix
      ../../users/kayon/modules/gnome-settings.nix
      ../../users/kayon/modules/tmux.nix
      ../../users/kayon/modules/git.nix
      ../../users/kayon/modules/zsh.nix
      
    ];

    services.arrpc.enable = true;

    

    home.packages = with pkgs; [
      vesktop # discord client
      arrpc # rich presence server
      steam
      calibre
      prismlauncher
      protonup-qt
      qbittorrent
      lutris
      qdirstat 
      wineWowPackages.stable
      onlyoffice-bin
      nil # nix language server

      # quickemu
      # owmods-cli
      rustdesk-flutter
      obsidian
      # nodejs
      # godot_4
      r2modman
      # rclone
    ];
  };
  
  environment.systemPackages = with pkgs; [
    blender
    firefox
    vlc
    gparted
    # exfatprogs # exfat drivers
    # ntfs3g # ntfs driver
    # gamescope
    # lm_sensors
  ];

  virtualisation.docker.enable = true;

  programs.direnv.enable = true;
  
  programs.zsh.enable = true;

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=3s
  '';
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=3s
  '';

  # run appimages with the appigame-run interpreter
  # programs.appimage.binfmt = true;
  
  # # Used to setup aarch64 oracle with nixos-anywhere  
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "jdy-desktop"; 

  boot.kernelPackages = pkgs.linuxPackages_latest; 

  networking.firewall.allowedTCPPorts = [ 25565 8080 ];

}
