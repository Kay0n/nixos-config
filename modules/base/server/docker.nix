{ nixos, ... }:
{
  # settings shared by every host
  flake.modules.nixos.docker = { pkgs, ... }: {

    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

  };
}
