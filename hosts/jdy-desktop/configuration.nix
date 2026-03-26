{ pkgs, lib, inputs, ... }: 

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };



  imports = [
    ../../modules/common.nix
    ../../users/kayon/system-load.nix
    ../../modules/pipewire.nix
    ../../modules/java.nix
    ../../modules/syncthing.nix
    ../../modules/niri/niri.nix
    ../../modules/firefox.nix
    ../../modules/llama.nix
    ../../secrets/sops.nix
  ];


  nixpkgs.overlays = [
    inputs.nixpkgs-xr.overlays.default

    (final: prev: {
      lmstudio = prev.lmstudio.override {
        version = "0.4.7-4";
        url = "https://installers.lmstudio.ai/linux/x64/0.4.7-4/LM-Studio-0.4.7-4-x64.AppImage";
        hash = "sha256-2dSgBr2B+PIUi/YCBmXDWXQWEEId6Qymh1JQuAPG/xU="; 
      };
    })

  ];


  programs.nix-index-database.comma.enable = true;

  # xbox controller driver
  # hardware.xone.enable = true;

  # services.flatpak = {
  #   enable = true;
  #   packages = [
  #     rec {
  #       appId = "com.hypixel.HytaleLauncher";
  #       sha256 = "sha256-iBYZTbm82X+CbF9v/7pwOxxxfK/bwlBValCAVC5xgV8=";
  #       bundle = "${pkgs.fetchurl {
  #         url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak";
  #         inherit sha256;
  #       }}";
  #     }
  #   ];
  # };

  
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






    home.packages = with pkgs; [
      vesktop # discord client
      # arrpc # rich presence server
      steam
      calibre
      prismlauncher
      protonup-qt
      qbittorrent
      # lutris
      qdirstat 
      onlyoffice-desktopeditors
      nil # nix language server

      # quickemu
      # owmods-cli
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


  networking.networkmanager.ensureProfiles.profiles = {
    quest-local = {
      connection = {
        interface-name = "enp8s0";
        id = "quest-local";
        permissions = "";
        type = "ethernet";
      };
      ipv4 = {
        method = "auto"; 
        route-metric = 800;
      };
    };
  };

  # programs.nix-ld.libraries = with pkgs; [
  #   alsa-lib
  #   openssl
  #   libgcc
  # ];



  # TODO: fix config not being applied
  # build fails 28-8-25
  # services.wivrn = {
  #   enable = true;
  #   package = pkgs.wivrn;
  #   openFirewall = true;
  #   autoStart = true;
  #   defaultRuntime = true;
  #   config = {
  #     enable = true;
  #     json = {
  #       scale = 1.0;
  #       # 100 Mb/s
  #       bitrate = 100000000;
  #       encoders = [
  #         {
  #           encoder = "vaapi";
  #           codec = "av1";
  #           width = 1.0;
  #           height = 1.0;
  #           offset_x = 0.0;
  #           offset_y = 0.0;
  #         }
  #       ];
  #       openvr-compat-path = pkgs.xrizer;
  #     };
  #   };
  # };


  # # attempt to get wlx-overlay-s input working
  # boot.kernelModules = [ "uinput" ];
  # hardware.uinput.enable = true;
  

  environment.systemPackages = with pkgs; [
    # lmstudio
    # inputs.glaumar_repo.packages.${pkgs.system}.qrookie
    # glaumar_repo.qrookie
    # blender
    # vlc
    # gparted
    # glaumar_repo.qrookie # QRookie bin, not working currently

    # music
    # ardour # daw
    # sfizz # sfz interface
    # nettools # for ifconfig

    # hub
    # godot

    # wlx-overlay-s
    # monado-vulkan-layers
    # opencomposite

    # android-tools
    # exfatprogs # exfat drivers
    # ntfs3g # ntfs driver
    # gamescope
    # lm_sensors
  ];


  virtualisation.docker.enable = true;


  # programs.direnv.enable = true;
  


  # # run appimages with the appimage-run interpreter
  # programs.appimage.binfmt = true;
  
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


  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
  '';

  networking.firewall.allowedTCPPorts = [ 9757 25565 50003 8080 27015 ];
  networking.firewall.allowedUDPPorts = [ 5353 9757 27015 ];

}


