{ nixos, ... }:
{
  # settings shared by every host
  flake.modules.nixos.default = { pkgs, ... }: {

    imports = with nixos; [
      home-manager
      comma
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10; # keep the 512M ESP from filling up
    boot.loader.efi.canTouchEfiVariables = true;

    time.timeZone = "Australia/Adelaide";

    i18n.defaultLocale = "en_AU.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };

    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
      ];
    };

    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      wget
      git
      python3
      tmux
      unzip
      devenv
    ];


    system.stateVersion = "24.11";

  };
}
