{ pkgs, lib, ... }: 

{

  imports = [
    ../../modules/common.nix
    ../../users/kayon/system-load.nix
    ../../modules/nvidia.nix
    ../../modules/pipewire.nix
    ../../modules/gnome.nix
    ../../modules/java.nix
    ../../modules/syncthing.nix
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

    home.packages = with pkgs; [
      vesktop # discord client
      # arrpc # discord rich presence server
      # steam
      # calibre
      prismlauncher
      # protonup-qt
      # qbittorrent
      # lutris
      # qdirstat
      # wineWowPackages.stable
      # winetricks
      onlyoffice-bin
      nil # nix language server

      # quickemu
      # owmods-cli
      # rustdesk-flutter
      obsidian
      # nodejs
      # godot_4
      # r2modman
      # protontricks
      # shell-gpt
      # rclone
      
    ];
  };
  
  environment.systemPackages = with pkgs; [
    # blender
    # (blender.override {cudaSupport = true;} ) # enable cuda, build from source
    firefox
    # vlc
    # appimage-run
    # gparted
    exfatprogs # exfat drivers
    ntfs3g # ntfs driver
    intel-gpu-tools
  ];

  virtualisation.docker.enable = true;

  services.logind.lidSwitch = "lock";

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

  networking.hostName = "jdy-laptop"; 


}
