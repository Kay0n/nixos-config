{ config, pkgs, ... }:

{

  imports = [
    ../../modules/common.nix
    ../../users/kayon/system-load.nix

    ../../modules/java.nix
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

  networking.hostName = "oracle-main";

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
  

  networking.firewall.allowedTCPPorts = [ 80 50000 50001 50002 55551 55552 55553 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;



}
