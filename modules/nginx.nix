{ pkgs, ... }:
{

  services.nginx.enable = true;

  services.nginx.virtualHosts = {
    "books.refract.online" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
        locations = {
          "/webdav/" = {
            proxyPass = "http://127.0.0.1:8085/";
          };
          "/" = {
            proxyPass = "http://127.0.0.1:8083";
          };
        };
    };

    "refract.online" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/";
        locations."/" = {
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
            '';
        };
    };
  };



  security.acme = {
    acceptTerms = true;
    defaults.email = "kayon5555@gmail.com";
  };

}