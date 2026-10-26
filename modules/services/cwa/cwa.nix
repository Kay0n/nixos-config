{ nixos, ... }:
{
  flake.modules.nixos.cwa = { config, lib, ... }: {

    imports = with nixos; [
      rclone-books
      cwa-pagecount
    ];

    options.cwa.dir = lib.mkOption {
      type = lib.types.str;
      default = "/home/kayon/book-automation/cwa";
      description = "Host directory holding the CWA config, ingest and library folders";
    };

    config.virtualisation.oci-containers.containers = {
      calibre-web-automated = {
        image = "crocodilestick/calibre-web-automated:v4.0.8";
        environment = {
          "PUID" = "1000";
          "PGID" = "1000";
          "TZ" = "Australia/Adelaide";

        };
        environmentFiles = [
          config.sops.secrets.hardcover_api_key.path
        ];
        volumes = [
          "${config.cwa.dir}/config:/config"
          "${config.cwa.dir}/ingest:/cwa-book-ingest"
          "${config.cwa.dir}/library:/calibre-library"
        ];
        ports = [ 
          "127.0.0.1:8083:8083"
        ];
      };
    };






  };
}
