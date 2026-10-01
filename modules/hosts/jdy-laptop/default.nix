{ nixos, ... }:
{
  # see also ./nvidia.nix
  flake.modules.nixos."hosts/jdy-laptop" = { pkgs, lib, ... }: {

    imports = with nixos; [
      ./_hardware-configuration.nix

      default
      desktop
      kayon
      # gnome
      # java
      syncthing
      firefox
      vscode
    ];


    # user specific settings   
    home-manager.users.kayon = {
      home.packages = with pkgs; [
        vesktop # discord client
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


  };
}
