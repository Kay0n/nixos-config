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


  
 
  services.openssh.enable = true;

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    zone = "refract.online";
    use = "web";
    passwordFile = "/run/secrets/cloudflare-token";
    interval = "5min";
    domains = [
      "mv.refract.online"
    ];
    extraConfig = ''
      web='https://cloudflare.com/cdn-cgi/trace'
      web-skip='ip='
    '';
  };
  

  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 50000 50001 50002 50005 22 ];
  
  networking.hostName = "mv-church";

  
}
