{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake-file.inputs.omnibin = {
    url = "github:fzakaria/omnibin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos."hosts/jdy-desktop" =
    { pkgs, lib, ... }:
    {
      imports = with nixos; [
        ./_hardware-configuration.nix
        inputs.omnibin.nixosModules.default

        base
        kayon
        nixpkgs-temp
        sops
        nix-index
        pipewire
        java
        syncthing
        niri
        firefox
        llama
        flatpak
        steam
        docker
      ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };


      programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "alacritty";
      };

      services.omnibin.enable = false;

      nixpkgs.overlays = [

        # (final: prev: {
        #   arnis = prev.arnis.overrideAttrs (old: {
        #   buildInputs = old.buildInputs ++ [
        #     final.glib
        #   ];
        #   });
        # })

      ];

      powerManagement.cpuFreqGovernor = "schedutil";

      programs.nix-index-database.comma.enable = true;

      # xbox controller driver
      # hardware.xone.enable = true;

      services.flatpak.packages = [
        # rec {
        #   appId = "com.hypixel.HytaleLauncher";
        #   sha256 = "sha256-iBYZTbm82X+CbF9v/7pwOxxxfK/bwlBValCAVC5xgV8=";
        #   bundle = "${pkgs.fetchurl {
        #     url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak";
        #     inherit sha256;
        #   }}";
        # }
        "org.vinegarhq.Sober" # if launch issues, run with:   flatpak run --socket=x11 org.vinegarhq.Sober
        "com.stremio.Stremio"
      ];


      home-manager.backupFileExtension = "backup"; # needed?

      # user specific settings
      home-manager.users.kayon = {
        imports = with homeManager; [
          vscode
          scripts
        ];

        services.arrpc.enable = true;



        # test fix for firefox audio cutout on different workspace

        home.packages = with pkgs; [
          vesktop # discord client
          # arrpc # rich presence server
          # calibre
          prismlauncher
          protonup-qt
          # qbittorrent
          # lutris
          onlyoffice-desktopeditors
          nil # nix language server

          # quickemu


          obsidian

          # nodejs
          # godot_4
          # r2modman
          # discord
          # nodejs
          # nmap
          # olympus
          heroic
          # sqlite
          # rclone

          (pkgs.writeShellScriptBin "winreboot" ''
            sudo ${pkgs.efibootmgr}/bin/efibootmgr -n 0003
            sudo reboot
          '')

        ];
      };

      # networking.networkmanager.ensureProfiles.profiles = {
      #   quest-local = {
      #     connection = {
      #       interface-name = "enp8s0";
      #       id = "quest-local";
      #       permissions = "";
      #       type = "ethernet";
      #     };
      #     ipv4 = {
      #       method = "auto";
      #       route-metric = 800;
      #     };
      #   };
      # };



      # programs.noisetorch.enable = true;

      programs.nix-ld.libraries = with pkgs; [
        # alsa-lib
        # openssl
        # libgcc
      ];





      environment.systemPackages = with pkgs; [
        # owmods-gui # wrong listed executable name?

        # nettools # for ifconfig

        # android-tools
        # exfatprogs # exfat drivers
        # ntfs3g # ntfs driver

      ];




      # # Used to setup aarch64 oracle with nixos-anywhere
      # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

      # services.ollama = {
      #   enable = true;
      #   package = pkgs.ollama-rocm;
      # };



      networking.hostName = "jdy-desktop";


      boot.kernelPackages = pkgs.linuxPackages_latest;


      # # for audio jacks to work
      # boot.extraModprobeConfig = ''
      #   options snd-hda-intel model=auto
      # '';

      programs.appimage = {
        enable = true;
        binfmt = true;
      };



      services.udev.extraRules = ''
        SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
      '';

      networking.firewall.allowedTCPPorts = [ 9757 25565 50003 8080 27015 ];
      networking.firewall.allowedUDPPorts = [ 5353 9757 27015 ];

    };
}
