{ ... }:
{
  flake.modules.homeManager.zsh = { pkgs, ... }: {

    # gh asks for background color
    home.sessionVariables.GLAMOUR_STYLE = "dark";

    programs.zsh = {  
      enable = true;
      initContent = ''
        eval "$(devenv hook zsh)" 
        bindkey '\t' autosuggest-accept
        ZSH_AUTOSUGGEST_STRATEGY=(completion history)

        # autoload -U add-zsh-hook

      '';

      shellAliases = {
        sshr = "ssh kayon@refract.online";
        ssha = "ssh kayon@amd.refract.online";
        ls = "ls -1 --color=auto";
        py = "python";
        nixrb = "nh os switch /home/kayon/.nixos-config";
        nixgc = "nh clean all --keep 2";
        clip = "${pkgs.wl-clipboard}/bin/wl-copy -n";
        rs = "rsync -avz --info=progress2";
        nixe = "code /home/kayon/.nixos-config & disown; exit";
        nix-shell = "NIXPKGS_ALLOW_UNFREE=1 nix-shell";
      };  

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      oh-my-zsh = {
        enable = true;
        theme = "intheloop";
      };

    };
  };
}
