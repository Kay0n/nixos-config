{ config, pkgs, ... }:

{

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
  
  programs.nix-ld.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 50000 50001 50002 55551 55552 55553 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  system.stateVersion = "23.11"; 

}
