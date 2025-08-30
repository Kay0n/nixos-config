{ config, pkgs, ... }:

{

  networking.hostName = "oracle-main";


  imports = [
    ../../users/kayon/system-load.nix
    ../../users/share/system-load.nix
    ../../modules/common.nix
    ../../modules/java.nix
    # ../../modules/dotnet.nix
    # ../../modules/nginx.nix # switch to caddy
    ../../modules/caddy.nix
    ../../modules/syncthing.nix
    ../../modules/xrdp.nix
  ];
  


  # user specific settings   
  home-manager.users.kayon = {
    imports = [
      ../../users/kayon
      ../../users/kayon/modules/tmux.nix
      ../../users/kayon/modules/git.nix
      ../../users/kayon/modules/zsh.nix
      ../../users/kayon/modules/vscode.nix
    ];

    home.packages = with pkgs; [
    ];
  };



  environment.systemPackages = with pkgs; [
    firefox
    # onlyoffice-bin
    libreoffice-qt6-fresh
  ];



  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      guacamole = import ../../containers/guacamole.nix;
      calibre-web-automated = import ../../containers/calibre-web-automated.nix;
    };
  };



  programs.zsh.enable = true;

  # services.tailscale = {
  #   enable = true;
  #   useRoutingFeatures = "server"; 
  #   openFirewall = true; # UDP 41641
  # };

  nixpkgs.overlays = [
  ];



  programs.nix-ld.enable = true;



  services.openssh = {
    enable = true;
    settings.GatewayPorts = "yes";
  };



  virtualisation.docker.enable = true;

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
    8083 8085 # calibre web autopmated
    8080 # xrdp?
    # 5900 6080 # x11vnc
  ];


}
