{ pkgs, lib, ... }: 

{

  imports = [
    ../../modules/common.nix
    ../../users/kayon/system-load.nix
    ./modules/nvidia.nix
    ../../modules/pipewire.nix
    # ../../modules/gnome.nix
    ../../modules/niri/niri.nix
    # ../../modules/java.nix
    ../../modules/syncthing.nix
    ../../modules/firefox.nix
  ];
  

  # user specific settings   
  home-manager.users.kayon = {
    imports = [
      ../../users/kayon
      ../../users/kayon/modules/vscode.nix
      # ../../users/kayon/modules/gnome-settings.nix
      ../../users/kayon/modules/tmux.nix
      ../../users/kayon/modules/git.nix
      ../../users/kayon/modules/zsh.nix
      ../../users/kayon/modules/scripts.nix
      
    ];

    home.packages = with pkgs; [
      vesktop # discord client
      onlyoffice-desktopeditors
      nil # nix language server
      obsidian
      
    ];
  };
  
  environment.systemPackages = with pkgs; [
  ];

  services.logind.lidSwitch = "lock";

  programs.zsh.enable = true;

  # systemd.extraConfig = ''
  #   DefaultTimeoutStopSec=3s
  # '';
  # systemd.user.extraConfig = ''
  #   DefaultTimeoutStopSec=3s
  # '';
  
  # # Used to setup aarch64 oracle with nixos-anywhere  
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "jdy-laptop"; 


}
