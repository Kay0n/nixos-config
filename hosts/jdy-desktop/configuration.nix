{ pkgs, lib, inputs, ... }: 

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };


  programs.nautilus-open-any-terminal = { 
    enable = true;
    terminal = "alacritty";
  };



  imports = [
    ../../modules/common.nix
    ../../users/kayon/system-load.nix
    ../../modules/pipewire.nix
    ../../modules/java.nix
    ../../modules/syncthing.nix
    ../../modules/niri/niri.nix
    ../../modules/firefox.nix
    ../../modules/llama/llama.nix
    ../../secrets/sops.nix
  ];


  nixpkgs.overlays = [
    inputs.nixpkgs-xr.overlays.default


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

  services.flatpak = {
    enable = true;
    packages = [
      # rec {
      #   appId = "com.hypixel.HytaleLauncher";
      #   sha256 = "sha256-iBYZTbm82X+CbF9v/7pwOxxxfK/bwlBValCAVC5xgV8=";
      #   bundle = "${pkgs.fetchurl {
      #     url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak";
      #     inherit sha256;
      #   }}";
      # }
      "org.vinegarhq.Sober" # run with:   flatpak run --socket=x11 org.vinegarhq.Sober
      "com.stremio.Stremio"
    ];
  };

  
  home-manager.backupFileExtension = "backup"; # needed?

  # user specific settings   
  home-manager.users.kayon = {
    imports = [
      ../../users/kayon
      ../../users/kayon/modules/vscode.nix
      ../../users/kayon/modules/tmux.nix
      ../../users/kayon/modules/git.nix
      ../../users/kayon/modules/zsh.nix
      ../../users/kayon/modules/scripts.nix
      
    ];

    services.arrpc.enable = true;



    # test fix for firefox audio cutout on different workspace

    home.packages = with pkgs; [
      vesktop # discord client
      # arrpc # rich presence server
      steam
      # calibre
      prismlauncher
      protonup-qt
      # qbittorrent
      # lutris
      qdirstat 
      onlyoffice-desktopeditors
      nil # nix language server

      # quickemu

      # rustdesk-flutter
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

      # services.ollama = {
    #   enable = true;
    #   package = pkgs.ollama-rocm;
    # };
    # services.open-webui.enable = true; # http://localhost:11434


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

  # programs.nix-ld.libraries = with pkgs; [
  #   alsa-lib
  #   openssl
  #   libgcc
  # ];





  environment.systemPackages = with pkgs; [
      owmods-gui

    # nettools # for ifconfig

    # android-tools
    # exfatprogs # exfat drivers
    # ntfs3g # ntfs driver

  ];


  virtualisation.docker.enable = true;



  
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

}


