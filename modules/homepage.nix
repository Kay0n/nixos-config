{ pkgs, config, inputs, ... }:

{

  # sops.secrets."homepage_env".mode = "0644";

  services.homepage-dashboard = {
    enable = true;

    allowedHosts = "refract.online,refract.online:443";

    settings = {
      title = "Oracle Homepage";
      theme = "dark";
    };

    environmentFiles = [config.sops.secrets."homepage_env".path];


    services = [
      {
        "Services" = [
          {
            "Caddy" = {
              icon = "caddy.png";
              href = "https://refract.online";

              widgets = [
                {
                  type = "caddy";
                  url = "http://localhost:2019";
                  fields = [
                    "upstreams"
                    "requests"
                    "requests_failed"
                  ];
                }
              ];
            };
          }

          {
            "Immich" = {
              icon = "immich.png";
              href = "https://immich.refract.online";

              widgets = [
                {
                  type = "immich";
                  url = "http://127.0.0.1:2283";
                  version = 2;

                  # Add your Immich API key here
                  key = "{{HOMEPAGE_VAR_IMMICH_KEY_KAYON}}";

                  fields = [
                    "users"
                    "photos"
                    "videos"
                    "storage"
                  ];
                }
              ];
            };
          }

          {
            "Calibre Web Automated" = {
              icon = "calibre.png";
              href = "https://books.refract.online";

              widgets = [
                {
                  type = "calibreweb";
                  url = "http://127.0.0.1:8083";

                  username = "kayon";
                  password = "{{HOMEPAGE_VAR_CALIBRE_WEB_AUTOMATED_KAYON}}";

                  fields = [
                    "books"
                    "authors"
                    "categories"
                    "series"
                  ];
                }
              ];
            };
          }

          {
            "Copyparty" = {
              icon = "copyparty.png";
              href = "https://files.refract.online";

            };
          }

          {
            "Guacamole" = {
              icon = "guacamole.png";
              href = "https://rdp.refract.online";

            };
          }
          
        ];
      }
    ];

    widgets = [
      {
        glances = {
          url = "http://localhost:61208";
          version = 4; 
          uptime = true;
          disk = [
            "/"
            "/mnt/rclone-immich-media/" # not sure how to track a second disk
          ];
        };
      }
    ];

    bookmarks = [];
  };

  nixpkgs.overlays = [
    (final: prev: {
      glances = prev.glances.overrideAttrs (oldAttrs: {
        disabledTests = (oldAttrs.disabledTests or []) ++ [
          "test_phys_core_returns_int"
        ];
      });
    })
  ];

  # services.glances = {
  #   enable = true;
  #   port = 61208;
  # };


}