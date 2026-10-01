{ homeManager, ... }:
{
  flake.modules.nixos.vscode = {
    home-manager.sharedModules = [ homeManager.vscode ];
  };

  flake.modules.homeManager.vscode = { pkgs, config, ... }: {

    xdg.configFile."Code/User/settings.json".source = config.lib.dotfiles.link ./settings.json;

    programs.vscode = {
      enable = true;

      profiles.default = {

        extensions = with pkgs.vscode-extensions; [
          # === base ===
          # ms-vscode-remote.remote-ssh

          # === java extensions ===
          # redhat.java
          # vscjava.vscode-java-debug
          # vscjava.vscode-maven
          # vscjava.vscode-java-dependency
          # vscjava.vscode-gradle


          # === nix === 
          jnoortheen.nix-ide # syntax and language support

          # === python ===
          # TODO: ty

          # === misc ===
          # rust-lang.rust-analyzer
          # svelte.svelte-vscode

        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          # {
          #   name = "godot-tools";
          #   publisher = "geequlim";
          #   version = "2.1.0";
          #   sha256 = "sha256-/0D4IJQXcjVtmX5gLKfEvviTQM595Y0EzCxlmVnsnJw=";
          # }
        ];

        keybindings = [
          {
            "key" = "tab";
            "command" = "-editor.action.inlineSuggest.commit";
          }
          {
            "key" = "f9"; # rebound as capslock in niri.nix
            "command" = "editor.action.inlineSuggest.commit";
            "when" = "editorTextFocus && inlineSuggestionVisible";
          }
        ];
      };
    };
  };
}
