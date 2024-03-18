{ config, pkgs, lib, ... }:

{
  # ----- common -----

  home.username = "kayon";
  home.homeDirectory = "/home/kayon";

  # home-manager version, do not touch
  home.stateVersion = "23.11"; 
  
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    zoxide
    neofetch
    xclip
    nil
  ];

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
      nixrb = "sudo nixos-rebuild switch --flake /home/kayon/.nixos-config/";
      clip = "xclip -r -selection clipboard";
      rs = "rsync -avz --info=progress2";
    };  
    
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "intheloop";
    };
  };

  programs.tmux = {
    enable = true;
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

}