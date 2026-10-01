{ nixos, ... }:
{


  flake.modules.nixos."hosts/jdy-desktop" = { pkgs, lib, ... }: {
    imports = with nixos; [
      ./_hardware-configuration.nix

      default
      desktop
      niri
      noctalia

      kayon

      syncthing

      java
      firefox
      vscode
      llama
      flatpak
      steam
      alacritty
    ];



    nixpkgs.overlays = [
    ];

    powerManagement.cpuFreqGovernor = "schedutil";

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



    # user specific settings
    home-manager.users.kayon = {
      services.arrpc.enable = true;

      home.packages = with pkgs; [
        vesktop # discord client
        # calibre
        prismlauncher
        protonup-qt
        # qbittorrent
        onlyoffice-desktopeditors
        nil # nix language server
        obsidian
        # nodejs
        # godot_4
        # r2modman
        heroic
        claude-code

        (pkgs.writeShellScriptBin "winreboot" ''
          sudo ${pkgs.efibootmgr}/bin/efibootmgr -n 0003
          sudo reboot
        '')

      ];
    };




    environment.systemPackages = with pkgs; [
      # exfatprogs # exfat drivers
      # ntfs3g # ntfs driver
    ];




    # # Used to setup aarch64 oracle with nixos-anywhere
    # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];







    boot.kernelPackages = pkgs.linuxPackages_latest;


    programs.appimage = {
      enable = true;
      binfmt = true;
    };



    services.udev.extraRules = ''
      SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
    '';

    networking.firewall.allowedTCPPorts = [ 9757 25565 50003 8080 27015 ];
    networking.firewall.allowedUDPPorts = [ 5353 9757 27015 ];

    networking.hostName = "jdy-desktop";

  };
}
