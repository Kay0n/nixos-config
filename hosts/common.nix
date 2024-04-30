{ config, pkgs, inputs, ... }:
{

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
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

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    git
    python3
    tmux
    unzip
    neovim
    temurin-jre-bin-17
  ];

  programs.java = {
    enable = true;
    package = pkgs.temurin-jre-bin-21;
  };
  
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  
}