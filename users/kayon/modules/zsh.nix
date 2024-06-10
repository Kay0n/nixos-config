
{ ... }: {

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
      nixrb = "sudo nixos-rebuild switch --flake";
      clip = "xclip -r -selection clipboard";
      rs = "rsync -avz --info=progress2";
      nixe = "code ~/.nixos-config/ && exit";
    };  
    
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "intheloop";
    };
  };
}



