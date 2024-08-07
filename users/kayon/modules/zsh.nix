
{ ... }: {

  programs.zsh = {  
    
    enable = true;
    
    initExtra = ''
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
      nixrb = "sudo nixos-rebuild switch --flake /etc/nixos";
      clip = "xclip -r -selection clipboard";
      rs = "rsync -avz --info=progress2";
      nixe = "code /etc/nixos && exit";
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



