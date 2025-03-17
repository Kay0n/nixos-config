{ pkgs, ... }:
{

  services.nginx.enable = true;

  services.nginx.virtualHosts = {
    "books.refract.online" = {
        # addSSL = true;
        enableACME = true;
        forceSSL = true;
        # root = "/var/www/";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8083";
        };
    };
    "refract.online" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/";
    };
  };



  security.acme = {
    acceptTerms = true;
    defaults.email = "kayon5555@gmail.com";
  };

}