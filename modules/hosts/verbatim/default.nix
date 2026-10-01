{ nixos, ... }:
{
  flake.modules.nixos."hosts/verbatim" = { pkgs, ... }: {

    networking.hostName = "verbatim";


    imports = with nixos; [
      ./_hardware-configuration.nix

      default
      desktop
      niri
      noctalia
      kayon

      firefox
      vscode
      alacritty

      # services
      syncthing
      
    ];



    environment.systemPackages = with pkgs; [
    ];





    networking.firewall.allowedTCPPorts = [
      22 # ssh
    ];


  };
}
