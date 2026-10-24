{ ... }:
{
  # Wisp proxy for celeste-wasm. Browsers can't open TCP/UDP sockets, so the
  # game tunnels all of its networking (CelesteNet, mod downloads) through
  # this. Behind authelia (see caddy.nix), so only logged-in users can use it
  flake.modules.nixos.wisp = { pkgs, ... }: let
    port = 4100;

    epoxy-server = pkgs.rustPlatform.buildRustPackage {
      pname = "epoxy-server";
      version = "2.0.0-unstable-2025";
      src = pkgs.fetchFromGitHub {
        owner = "MercuryWorkshop";
        repo = "epoxy-tls";
        rev = "9cde724aea1a0f5e46b1c962b3d19ca1389af074";
        hash = "sha256-jPLMAPmqwAkHc+bg2tbfYv/c/O2B5uV+yaD/qU+V+EM=";
      };
      cargoHash = "sha256-fSlSimvs4LoI1H8MQp+/XP8Qw+GO1Jd3OIMC1hc5FmE=";

      buildAndTestSubdir = "server";
      nativeBuildInputs = [ pkgs.pkg-config ];
      doCheck = false;
    };

    config = (pkgs.formats.toml { }).generate "epoxy-server.toml" {
      server = {
        bind = [ "tcp" "127.0.0.1:${toString port}" ];
        # caddy is in front of it
        use_real_ip_headers = true;
      };
      wisp = {
        allow_wsproxy = false;
      };
      stream = {
        allow_loopback = false;
        allow_non_global = false;
        allow_multicast = false;
        # only http(s) for mod downloads, and CelesteNet
        block_ports = [ [ 0 65535 ] ];
        allow_ports = [ [ 80 80 ] [ 443 443 ] [ 17230 17230 ] ];
      };
    };
  in {
    systemd.services.wisp = {
      description = "Wisp proxy for celeste-wasm";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${epoxy-server}/bin/epoxy-server ${config}";
        DynamicUser = true;
        Restart = "always";
      };
    };
  };
}
