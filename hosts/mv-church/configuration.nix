{ config, pkgs, ... }:

{

  networking.hostName = "mv-church";
 
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


  networking.firewall.allowedTCPPorts = [ 50000 50001 50002 50005 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  system.stateVersion = "23.11"; 

}
