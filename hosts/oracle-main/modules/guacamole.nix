{ ... }:
{
  virtualisation.oci-containers.containers.guacamole = {
    image = "jwetzell/guacamole:1.5.5";
    ports = [ "127.0.0.1:6938:8080" ];
    volumes = [
      "/home/kayon/guac:/config"  
    ];
    environment = {
      # EXTENSIONS = "auth-totp";
    };
    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
    ];
  };
}

