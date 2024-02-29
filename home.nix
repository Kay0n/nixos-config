{ config, pkgs, lib, ... }:

{
  home.username = "kayon";
  home.homeDirectory = "/home/kayon";

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

  programs.git = {
    enable = true;
    userName = "Kay0n";
    userEmail = "kayon5555@gmail.com";
  };

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

  home.sessionVariables = {
  };

  # home-manager version, do not touch
  home.stateVersion = "23.11"; 
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}



