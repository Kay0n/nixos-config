{ nixos, ... }:
{
  flake.modules.nixos."hosts/oracle-main" = { pkgs, ... }: {

    networking.hostName = "oracle-main";


    imports = with nixos; [
      ./_hardware-configuration.nix

      default
      sops
      kayon
      share

      java
      firefox
      vscode

      # services
      syncthing
      caddy
      copyparty
      cwa
      xrdp
      guacamole
      celestenet
      immich
      homepage
    ];



    environment.systemPackages = with pkgs; [
      # onlyoffice-bin
      libreoffice-qt6-fresh
      calibre
    ];


    services.openssh = {
      enable = true;
      settings.GatewayPorts = "yes";
    };



    # services.ddclient = {
    #   enable = true;
    #   protocol = "cloudflare";
    #   zone = "refract.online";
    #   use = "web";
    #   passwordFile = "/run/secrets/cloudflare-token";
    #   interval = "5min";
    #   domains = [
    #     "refract.online"
    #     "alt.refract.online"
    #     "mini.refract.online"
    #   ];
    #   extraConfig = ''
    #     web='https://cloudflare.com/cdn-cgi/trace'
    #     web-skip='ip='
    #   '';
    # };



    networking.firewall.allowedTCPPorts = [
      443 80 # http/s
      25565 50000 50001 50002 # mc
      55551 55552 55553 # share
      22 # ssh
    ];


  };
}
