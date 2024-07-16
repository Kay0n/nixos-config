{ pkgs, ... }:
{

  services.nginx.enable = true;

  services.nginx.virtualHosts."refract.online" = {
      addSSL = true;
      enableACME = true;
      root = "/var/www/";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "kayon5555@gmail.com";
  };

}
