{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos."hosts/mv-church" =
    { options, pkgs, ... }:
    {

      networking.hostName = "mv-church";

      imports = with nixos; [
        ./_hardware-configuration.nix

        base
        kayon
        java
      ];


      environment.systemPackages = with pkgs; [
      ];

      programs.zsh.enable = true;

      services.openssh.enable = true;

      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = options.programs.nix-ld.libraries.default ++ (with pkgs; [ 
        icu
      ]);


      services.ddclient = {
        enable = true;
        protocol = "cloudflare";
        zone = "refract.online";
        use = "web";
        passwordFile = "/run/secrets/cloudflare-token";
        interval = "5min";
        domains = [
          "mv.refract.online"
        ];
        extraConfig = ''
          web='https://cloudflare.com/cdn-cgi/trace'
          web-skip='ip='
        '';
      };

      networking.firewall.allowedTCPPorts = [ 50000 50001 50002 50005 22 ];

    };
}
