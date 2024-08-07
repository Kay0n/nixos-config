{ pkgs, ... }:
{

  services.nginx.enable = true;

  services.nginx.virtualHosts."refract.online" = {
      # addSSL = true;
      enableACME = true;
      forceSSL = true;
      # root = "/var/www/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
      };
  };



  security.acme = {
    acceptTerms = true;
    defaults.email = "kayon5555@gmail.com";
  };

}