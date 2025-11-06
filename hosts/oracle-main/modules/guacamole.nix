{ ... }:
{
  virtualisation.oci-containers.containers.guacamole = {
    image = "jwetzell/guacamole:1.5.5";
    ports = [ "6938:8080" ];
    volumes = [
      "/home/kayon/guac:/config"  
    ];
    environment = {
      # EXTENSIONS = "auth-totp";
    };
    extraOptions = [
      # connects to host xrdp on host.docker.internal:3389
      "--add-host=host.docker.internal:host-gateway"
    ];
  };
}

