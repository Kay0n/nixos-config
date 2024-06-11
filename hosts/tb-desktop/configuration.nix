{ pkgs, lib, ... }: 

{

  # override bootloader to grub
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  # boot.loader.grub.enable = lib.mkForce true;
  # boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.useOSProber = true;


  imports = [
    ../../modules/common.nix
    ../../users/kayon/system-load.nix

    ../../modules/nvidia.nix
    ../../modules/pipewire.nix
    ../../modules/gnome.nix
    ../../modules/java.nix
    
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
      
    ];
  };
  

  environment.systemPackages = with pkgs; [
    firefox
    vlc
    appimage-run
    gparted
  ];

  programs.zsh.enable = true;

  # run appimages with the appigame-run interpreter
  programs.appimage.binfmt = true;


  # # Used to setup aarch64 oracle with nixos-anywhere  
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "tb-desktop"; 



}
