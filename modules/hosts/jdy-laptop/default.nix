{ nixos, ... }:
{
  # see also ./nvidia.nix
  flake.modules.nixos."hosts/jdy-laptop" = { pkgs, lib, ... }: {

    imports = with nixos; [
      ./_hardware-configuration.nix

      default
      desktop
      niri
      noctalia
      kayon
      # java
      syncthing
      firefox
      vscode
      alacritty
    ];


    # user specific settings   
    home-manager.users.kayon = {
      home.packages = with pkgs; [
        vesktop 
        onlyoffice-desktopeditors
        nil # nix language server
        obsidian

      ];
    };

    services.logind.settings.Login.HandleLidSwitch = "lock";

    # systemd.extraConfig = ''
    #   DefaultTimeoutStopSec=3s
    # '';
    # systemd.user.extraConfig = ''
    #   DefaultTimeoutStopSec=3s
    # '';

    # # Used to setup aarch64 oracle with nixos-anywhere  
    # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    networking.hostName = "jdy-laptop"; 

    system.stateVersion = "24.11"; # install release, do not change
  };
}
