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
    ../../modules/hyprland
    ../../modules/firefox.nix
    ../../secrets/sops.nix
  ];


  nixpkgs.overlays = [
    (final: prev: {
      glaumar_repo = inputs.glaumar_repo.packages."${prev.system}";
    })
    inputs.nixpkgs-xr.overlays.default
  ];

  # fixes for gpu crashes under load - effectiveness tbd
  # prevent amdgup crashes (overvolt?) see https://discourse.nixos.org/t/yet-another-gcvm-l2-protection-fault-status-problem/65420/10
  boot.kernelParams = [ 
    "amdgpu.ppfeaturemask=0xf7fff" # disable "PP_GFXOFF_MASK" dynamic graphics engine     
    # "amdgpu.aspm=0" # disable pcie active state power management
    # "amdgpu.bapm=0" # disable bidirectional application CPU/GPU TDP power management
    # "amdgpu.runpm=0" # disable runtime power management
    # "pcie_aspm=off" # disable active state power management
  ];

  # xbox controller driver
  hardware.xone.enable = true;


  
  home-manager.backupFileExtension = "backup";

  # user specific settings   
  home-manager.users.kayon = {
    imports = [
      ../../users/kayon
      ../../users/kayon/modules/vscode.nix
      ../../users/kayon/modules/gnome-settings.nix
      ../../users/kayon/modules/tmux.nix
      ../../users/kayon/modules/git.nix
      ../../users/kayon/modules/zsh.nix
      
    ];

    services.arrpc.enable = true;



    # # for roblox
    # services.flatpak = {
    #   enable = true;
    #   packages = [
    #     "com.obsproject.Studio"
    #     "im.riot.Riot"
    #   ];
    # };



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
      onlyoffice-desktopeditors
      nil # nix language server

      # quickemu
      owmods-cli
      rustdesk-flutter
      obsidian
      # nodejs
      # godot_4
      r2modman
      discord
      nodejs
      nmap
      olympus
      # sqlite
      # rclone

      (pkgs.writeShellScriptBin "winreboot" ''
        sudo ${pkgs.efibootmgr}/bin/efibootmgr -n 0003
        sudo reboot
      '')
    
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

  # programs.nix-ld.enable = true;
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
    blender
    vlc
    gparted
    clinfo
    # glaumar_repo.qrookie # QRookie bin, not working currently

    # music
    ardour # daw
    sfizz # sfz interface
    nettools # for ifconfig

    hub
    godot

    # wlx-overlay-s
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

  # # run appimages with the appigame-run interpreter
  # programs.appimage.binfmt = true;
  
  # # Used to setup aarch64 oracle with nixos-anywhere  
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "jdy-desktop"; 


  boot.kernelPackages = pkgs.linuxPackages_latest; 


  # # for audio jacks to work
  # boot.extraModprobeConfig = ''
  #   options snd-hda-intel model=auto
  # '';


  networking.firewall.allowedTCPPorts = [ 9757 25565 50003 8080 ];
  networking.firewall.allowedUDPPorts = [ 5353 9757 ];

}
