
{ pkgs, ... }: {


  programs.zsh = {  
    
    enable = true;
    
    initContent = ''
      # eval "$(devenv hook zsh)" # wait for devenv 2.1 in nixpkgs 
      bindkey '\t' autosuggest-accept
      ZSH_AUTOSUGGEST_STRATEGY=(completion history)

      find_devenv_nix() {
        local dir="$PWD"
        local count=0
        local max=8
        while [[ $count -lt $max && "$dir" != "/" ]]; do
          if [[ -f "$dir/devenv.nix" ]]; then
            if ! head -n 1 "$dir/devenv.nix" | grep -q '# @autorun'; then
              dir=$(dirname "$dir")
              ((count++))
              continue
            fi
            echo "$dir"
            return 0
          fi
          dir=$(dirname "$dir")
          ((count++))
        done
        return 1
      }
      enter_devenv_if_needed() {
        [[ -n "$DEVENV_ROOT" ]] && return
        [[ -n "$_DEVENV_ENTERING" ]] && return  # recursion guard
        local target
        target=$(find_devenv_nix) || return 0
        [[ -z "$target" ]] && return 0

        export _DEVENV_ENTERING=1
        export ORIG="$PWD"
        cd "$target" || return
        exec devenv shell "zsh -c 'cd \"$ORIG\"; zsh -i'"
      }
      devenv_cd_hook() {
        enter_devenv_if_needed
      }

      autoload -U add-zsh-hook
      add-zsh-hook chpwd devenv_cd_hook
      devenv_cd_hook
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



