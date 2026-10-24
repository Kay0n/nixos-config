{ ... }:
{
  flake.modules.nixos.caddy = { pkgs, ... }: {
    services.caddy = {
      enable = true;

      # snippets for authelia (see authelia.nix)
      #   private site:   `import authelia` before reverse_proxy
      #   public + login: `import authelia_split 127.0.0.1:<port>`
      extraConfig = ''
        # forward_auth already drops client-sent copies of copy_headers (no spoofing)
        (authelia) {
          forward_auth 127.0.0.1:9091 {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
          }
        }

        (strip_identity) {
          request_header -Remote-User
          request_header -Remote-Groups
          request_header -Remote-Email
          request_header -Remote-Name
        }

        # for sites with public and private endpoints
        (authelia_split) {
          @loggedin header_regexp Cookie (^|;\s*)authelia_session=
          handle @loggedin {
            import authelia
            reverse_proxy {args[0]}
          }
          handle {
            import strip_identity
            reverse_proxy {args[0]}
          }
        }
      '';

      virtualHosts = {
        "login.refract.online" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:9091
          '';
        };

        "refract.online" = {
          extraConfig = ''
            import authelia
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

            # enable reverse proxy auth in cwa settings
            handle {
              import authelia_split 127.0.0.1:8083
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

        "celeste.refract.online" = {
          extraConfig = ''
            # hashed runtime/bundle files: public, cached forever, no auth
            # (dotnet.js isn't hashed, so it stays behind login and revalidates)
            @hashed {
              path /_framework/* /assets/*
              not path /_framework/dotnet.js
            }
            handle @hashed {
              import strip_identity
              reverse_proxy 127.0.0.1:8947 {
                header_down Cache-Control "public, max-age=31536000, immutable"
              }
            }

            # wisp proxy celeste-wasm
            handle /wisp/* {
              import authelia
              reverse_proxy 127.0.0.1:4100
            }

            handle {
              import authelia
              reverse_proxy 127.0.0.1:8947
            }
          '';
        };

        "rdp.refract.online" = {
          extraConfig = ''
            import authelia
            # guacamole auth-header ext reads REMOTE_USER by default
            request_header REMOTE_USER {http.request.header.Remote-User}
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

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 443 ]; # http/3
  };
}
