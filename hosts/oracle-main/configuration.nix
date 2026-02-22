{ config, pkgs, ... }:

{

  networking.hostName = "oracle-main";


  imports = [
    ../../users/kayon/system-load.nix
    ../../users/share/system-load.nix
    ../../modules/common.nix
    ../../modules/java.nix
    ../../modules/syncthing.nix
    ../../modules/firefox.nix
    ../../secrets/sops.nix

    # host specific imports
    ./modules/copyparty.nix
    ./modules/cwa.nix
    ./modules/caddy.nix
    ./modules/xrdp.nix
    ./modules/guacamole.nix
    ./modules/rclone.nix
    ./modules/celestenet.nix
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
    # onlyoffice-bin
    libreoffice-qt6-fresh
    calibre
  ];



  virtualisation.oci-containers.backend = "docker";



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
    # 8083 8085 # calibre web automated
    # 8080 # xrdp?
    # 5900 6080 # x11vnc
  ];


}
