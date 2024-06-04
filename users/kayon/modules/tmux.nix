
{ ... }: {

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



