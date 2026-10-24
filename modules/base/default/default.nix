{ nixos, ... }:
{
  # settings shared by every host
  flake.modules.nixos.default = { pkgs, ... }: {

    imports = with nixos; [
      home-manager
      comma
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    # lets wheel users add substituters (devenv caches), kayon already has sudo anyway
    nix.settings.trusted-users = [ "root" "@wheel" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 20; # keep the 512M ESP from filling up
    boot.tmp.cleanOnBoot = true;

    zramSwap.enable = true; # compressed swap in RAM
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

    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
      ];
    };

    programs.zsh.enable = true;

    programs.nh = {
      enable = true;
      flake = "/home/kayon/.nixos-config";
      clean = {
        enable = true;
        extraArgs = "--keep 3 --keep-since 7d --nogcroots";
      };
    };

    environment.systemPackages = with pkgs; [
      wget
      git
      python3
      tmux
      unzip
      devenv
    ];


  };
}
