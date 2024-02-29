{ config, pkgs, lib, ... }:

{
  # ----- common -----

  home.username = "kayon";
  home.homeDirectory = "/home/kayon";

  # home-manager version, do not touch
  home.stateVersion = "23.11"; 
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  programs.git = {
    enable = true;
    userName = "Kay0n";
    userEmail = "kayon5555@gmail.com";
  };


  programs.zsh = {  
    
    enable = true;
    
    initExtra = ''
      eval "$(zoxide init zsh)"
      bindkey '\t' autosuggest-accept
      ZSH_AUTOSUGGEST_STRATEGY=(completion history)
      unsetopt beep
    '';

    shellAliases = {
      sshr = "ssh kayon@refract.online";
      ssha = "ssh kayon@amd.refract.online";
      sshm = "ssh kayon@mv.refract.online";
      ls = "ls -1 --color=auto";
      py = "python";
      cd = "z";
      nixrb = "sudo nixos-rebuild switch";
    };  

    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "intheloop";
    };
  };


  programs.tmux = {
    enable = true;
    # Custom tmux configuration
    extraConfig = ''
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      bind | split-window -h
      bind - split-window -v

      set -g mouse on

      set-option -g allow-rename
    '';
  };





  # ----- display -----

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style.name = "adwaita-dark";
  };

  home.packages = with pkgs; [
    zoxide
    discord
    vscode
    steam
    calibre
    prismlauncher
    protonup-qt
    qbittorrent
    lutris
    wineWowPackages.stable
    neofetch
    nil
  ];

  

  





  dconf.settings = { 

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/desktop/wm/keybindings" = {
      toggle-fullscreen = [ "<Super>r" ];
      close = [ "<Super>q" ];
      show-desktop = [ "<Super>d" ];
      switch-windows = ["<Alt>Tab"];
      switch-windows-backward = ["<Shift><Alt>Tab"];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
      home = [ "<Super>e" ];
      control-center = [ "<Super>i" ];
      www = [ "<Super>f" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>t";
      command = "kgx";
      name = "GNOME Console";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Shift><Control>Escape";
      command = "gnome-system-monitor";
      name = "System Moniter";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>m";
      command = "code";
      name = "VSCode";
    };


    
  };

  
}



