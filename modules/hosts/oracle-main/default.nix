{ nixos, ... }:
{
  flake.modules.nixos."hosts/oracle-main" = { pkgs, ... }: {

    networking.hostName = "oracle-main";


    imports = with nixos; [
      ./_hardware-configuration.nix

      default
      sops
      docker
      kayon
      share

      java
      firefox
      vscode

      # services
      syncthing
      caddy
      authelia
      copyparty
      cwa
      xrdp
      guacamole
      celestenet
      immich
      homepage
      celeste-wasm
      wisp
    ];



    environment.systemPackages = with pkgs; [
      # onlyoffice-bin
      libreoffice-qt-stable
      calibre
      claude-code
    ];


    services.openssh = {
      enable = true;
      settings.GatewayPorts = "yes";
    };

    # 5 failures - 10m ban, doubles each ban
    services.fail2ban = {
      enable = true;
      bantime-increment.enable = true;
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
      25565 50000 50001 50002 # mc
    ];

    system.stateVersion = "24.11"; # install release, do not change
  };
}
