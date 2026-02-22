
{ pkgs, ... }: {


  programs.zsh = {  
    
    enable = true;
    
    initContent = ''

      bindkey '\t' autosuggest-accept
      ZSH_AUTOSUGGEST_STRATEGY=(completion history)
      # unsetopt beep # disable bell sound on backspace

      # alias/command for `nix shell nixpkgs#<pgk_name>`
      pkg() {
        if [ -z "$1" ]; then
          echo "Usage: pkg <package-name>"
          return 1
        fi
        echo "Adding package $1 to shell environment..."
        nix shell "nixpkgs#$1"
      }

    '';

    shellAliases = {
      sshr = "ssh kayon@refract.online";
      ssha = "ssh kayon@amd.refract.online";
      sshm = "ssh kayon@mv.refract.online";
      ls = "ls -1 --color=auto";
      py = "python";
      nixrb = "sudo nixos-rebuild switch --flake /home/kayon/.nixos-config";
      clip = "${pkgs.xclip} -r -selection clipboard";
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



