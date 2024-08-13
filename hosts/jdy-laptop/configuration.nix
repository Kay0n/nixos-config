{ pkgs, lib, ... }: 

{


  imports = [
    ../../modules/common.nix
    ../../users/kayon/system-load.nix

    ../../modules/nvidia.nix
    ../../modules/pipewire.nix
    ../../modules/gnome.nix
    ../../modules/java.nix
    ../../modules/dotnet.nix
    
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
      winetricks
      libreoffice
      nil # nix language server

      quickemu
      owmods-cli
      rustdesk-flutter
      obsidian
      nodejs
      
    ];
  };
  
  environment.systemPackages = with pkgs; [
    firefox
    vlc
    appimage-run
    gparted
  ];

  virtualisation.docker.enable = true;

  services.tailscale.enable = true;

  programs.zsh.enable = true;

  # run appimages with the appigame-run interpreter
  # programs.appimage.binfmt = true;
  
  # # Used to setup aarch64 oracle with nixos-anywhere  
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "jdy-laptop"; 



}
