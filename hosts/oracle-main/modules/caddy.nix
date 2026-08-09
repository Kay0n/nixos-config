{ pkgs, ... }:
{
  services.caddy = {
    enable = true;

    virtualHosts = {
      "refract.online" = {
        extraConfig = ''
          handle {
            reverse_proxy 127.0.0.1:8082
          }
        '';
      };
      "books.refract.online" = {
        extraConfig = ''
          handle_path /webdav/* {
            reverse_proxy 127.0.0.1:8085
          }

          handle {
            reverse_proxy 127.0.0.1:8083
          }
        '';
      };

      # "index.refract.online" = {
      #   extraConfig = ''
      #     root * /var/www/
      #     file_server {
      #       browse
      #     }
      #   '';
      # };

      "rdp.refract.online" = {
        extraConfig = ''
          handle {
            reverse_proxy 127.0.0.1:6938
          }
        '';
      };  
      "files.refract.online" = {
        extraConfig = ''
          handle {
            reverse_proxy 127.0.0.1:3923
          }
        '';
      };  
      "immich.refract.online" = {
        extraConfig = ''
          handle {
            reverse_proxy 127.0.0.1:2283
          }
        '';
      };  
    };
  };
}
