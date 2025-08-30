
{ pkgs, ... }: 
let
  nixCommandCache = ''
    NIX_CMD_CACHE="$HOME/.cache/nix-command-cache"
    # mkdir -p "$(dirname "$NIX_CMD_CACHE")"

    command_not_found_handler() {
      local cmd="$1"
      shift

      # check if nix-index database exists
      if [ ! -e "$HOME/.cache/nix-index/files" ]; then
        echo "zsh: command not found: $cmd"
        echo "[nix-index db not found]: Run nix-index to generate"
        return 127
      fi

      # try cache lookup at NIX_CMD_CACHE
      local pkg
      pkg=$(grep -E "^''${cmd} " "$NIX_CMD_CACHE" 2>/dev/null | awk '{print $2}' | head -n1)

      # resolve with nix-locate
      if [[ -z "$pkg" ]]; then
        pkg=$(nix-locate --minimal --type x --whole-name "bin/$cmd" | head -n1)
        if [[ -n "$pkg" ]]; then
          echo "$cmd $pkg" >> "$NIX_CMD_CACHE"
        fi
      fi

      # run with discovered package
      if [[ -n "$pkg" ]]; then
        echo "[$cmd not found]: Found in 'nixpkgs#$pkg'."
        read -k 1 'response?Press y to run, or any other key to cancel: '
        echo # Move to a new line after input

        if [[ "$response" == "y" ]]; then
          echo "Running with nix run nixpkgs#$pkg ..."
          nix run "nixpkgs#$pkg" -- "$@"
        else
          echo "Operation cancelled."
          return 1
        fi

      else
        echo "zsh: command not found: $cmd"
        return 127
      fi
    }

  ''; 
in
{

  home.packages = [
    pkgs.nix-index
  ];

  programs.zsh = {  
    
    enable = true;
    
    initContent = ''
      ${nixCommandCache}
      
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



