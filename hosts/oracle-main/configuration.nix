{ config, pkgs, ... }:

{

  networking.hostName = "oracle-main";

  imports = [
    ../../users/kayon/system-load.nix
    ../../users/share/system-load.nix
    ../../modules/common.nix
    ../../modules/java.nix
    ../../modules/dotnet.nix
    ../../modules/nginx.nix
  ];
  

  # user specific settings   
  home-manager.users.kayon = {
    imports = [
      ../../users/kayon
      ../../users/kayon/modules/tmux.nix
      ../../users/kayon/modules/git.nix
      ../../users/kayon/modules/zsh.nix
    ];

    home.packages = with pkgs; [
    ];
  };
  

  environment.systemPackages = with pkgs; [
  ];

  programs.zsh.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server"; 
    openFirewall = true; # UDP 41641
  };

  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    settings.GatewayPorts = "yes";
  };

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    zone = "refract.online";
    use = "web";
    passwordFile = "/run/secrets/cloudflare-token";
    interval = "5min";
    domains = [
      "refract.online"
      "alt.refract.online"
      "mini.refract.online"
    ];
    extraConfig = ''
      web='https://cloudflare.com/cdn-cgi/trace'
      web-skip='ip='
    '';
  };
  

  networking.firewall.allowedTCPPorts = [ 443 80 50000 50001 50002 55551 55552 55553 22 ];




}