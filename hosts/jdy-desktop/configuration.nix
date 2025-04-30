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
    ../../modules/gnome.nix
    ../../modules/java.nix
    ../../modules/syncthing.nix
    # ../../modules/dotnet.nix
    
  ];


  nixpkgs.overlays = [
    (final: prev: {
      glaumar_repo = inputs.glaumar_repo.packages."${prev.system}";
    })
    inputs.nixpkgs-xr.overlays.default
  ];


  # user specific settings   
  home-manager.users.kayon = {
    imports = [
      ../../users/kayon
      # ../../users/kayon/modules/vscode.nix
      ../../users/kayon/modules/gnome-settings.nix
      ../../users/kayon/modules/tmux.nix
      ../../users/kayon/modules/git.nix
      ../../users/kayon/modules/zsh.nix
      
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
      lutris
      qdirstat 
      wineWowPackages.stable
      onlyoffice-bin
      nil # nix language server

      # quickemu
      owmods-cli
      # rustdesk-flutter
      obsidian
      # nodejs
      # godot_4
      r2modman
      discord
      nodejs
      # sqlite
      # rclone
    ];
  };


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


  # TODO: fix config not being applied
  services.wivrn = {
    enable = true;
    package = pkgs.wivrn;
    openFirewall = true;
    autoStart = true;
    defaultRuntime = true;
    config = {
      enable = true;
      json = {
        scale = 1.0;
        # 100 Mb/s
        bitrate = 100000000;
        encoders = [
          {
            encoder = "vaapi";
            codec = "av1";
            width = 1.0;
            height = 1.0;
            offset_x = 0.0;
            offset_y = 0.0;
          }
        ];
        openvr-compat-path = pkgs.xrizer;
      };
    };
  };


  # # attempt to get wlx-overlay-s input working
  boot.kernelModules = [ "uinput" ];
  hardware.uinput.enable = true;
  

  environment.systemPackages = with pkgs; [
    blender
    firefox
    vlc
    gparted
    vscode-fhs
    clinfo
    glaumar_repo.qrookie
    wlx-overlay-s
    # monado-vulkan-layers
    # opencomposite

    android-tools
    # exfatprogs # exfat drivers
    # ntfs3g # ntfs driver
    # gamescope
    # lm_sensors
  ];


  virtualisation.docker.enable = true;


  programs.direnv.enable = true;
  

  programs.zsh.enable = true;

  # # Dont know if this is neccesary
  # systemd.extraConfig = ''
  #   DefaultTimeoutStopSec=3s
  # '';
  # systemd.user.extraConfig = ''
  #   DefaultTimeoutStopSec=3s
  # '';

  # # run appimages with the appigame-run interpreter
  # programs.appimage.binfmt = true;
  
  # # Used to setup aarch64 oracle with nixos-anywhere  
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "jdy-desktop"; 


  boot.kernelPackages = pkgs.linuxPackages_latest; 


  networking.firewall.allowedTCPPorts = [ 9757 25565 8080 ];
  networking.firewall.allowedUDPPorts = [ 5353 9757 ];

}
