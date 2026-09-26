{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos."hosts/oracle-main" =
    { pkgs, ... }:
    {

      networking.hostName = "oracle-main";


      imports = with nixos; [
        ./_hardware-configuration.nix

        base
        kayon
        share
        sops
        nix-index
        docker
        java
        syncthing
        firefox

        # services
        copyparty
        cwa
        caddy
        xrdp
        guacamole
        rclone-books
        celestenet
        immich
        homepage
      ];



      # user specific settings
      home-manager.users.kayon = {
        imports = with homeManager; [
          vscode
          scripts
        ];

        home.packages = with pkgs; [
        ];
      };



      environment.systemPackages = with pkgs; [
        # onlyoffice-bin
        libreoffice-qt6-fresh
        calibre
      ];



      virtualisation.oci-containers.backend = "docker";



      programs.zsh.enable = true;


      programs.nix-ld.enable = true;



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
        # 8083 8085 # calibre web automated
        # 5900 6080 # x11vnc
      ];


    };
}
