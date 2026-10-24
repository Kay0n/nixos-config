{ ... }:
{
  flake.modules.nixos.guacamole = { pkgs, ... }: let
    # guacamole extension (a zip named .jar) that injects ./keyboard-lock.js into the web app.
    # its name must not contain "guacamole", or the image's startup script deletes it
    keyboard-lock = pkgs.runCommand "keyboard-lock.jar" { nativeBuildInputs = [ pkgs.zip ]; } ''
      cp ${./keyboard-lock.js} keyboard-lock.js
      cp ${pkgs.writeText "guac-manifest.json" (builtins.toJSON {
        guacamoleVersion = "*";
        name = "Keyboard Lock";
        namespace = "keyboard-lock";
        js = [ "keyboard-lock.js" ];
      })} guac-manifest.json
      zip -X $out guac-manifest.json keyboard-lock.js
    '';
  in {
    virtualisation.oci-containers.containers.guacamole = {
      image = "jwetzell/guacamole:1.5.5";
      ports = [ "127.0.0.1:6938:8080" ];
      volumes = [
        "/home/kayon/guac:/config"
        "${keyboard-lock}:/config/guacamole/extensions/keyboard-lock.jar:ro"
      ];
      environment = {
        EXTENSIONS = "auth-header";
      };
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
    };
  };
}
