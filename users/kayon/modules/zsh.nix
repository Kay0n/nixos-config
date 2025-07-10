
{ ... }: {

  programs.zsh = {  
    
    enable = true;
    
    initContent = ''
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
      nixrb = "sudo nixos-rebuild switch --flake /home/kayon/.nixos-config";
      clip = "xclip -r -selection clipboard";
      rs = "rsync -avz --info=progress2";
      nixe = "code /home/kayon/.nixos-config & disown; exit";
      hypre = "code /home/kayon/.config/hypr/hyprland.conf & disown; exit";
    };  
    
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "intheloop";
    };
  };
}



