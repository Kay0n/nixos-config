
{ pkgs, ... }: {

  programs.vscode = {
    enable = true;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      # === base ===
      ms-vscode-remote.remote-ssh
      visualstudioexptteam.vscodeintellicode

      # === java extensions ===
      redhat.java
      vscjava.vscode-java-debug
      vscjava.vscode-maven
      vscjava.vscode-java-dependency
      vscjava.vscode-gradle


      # === nix === 
      jnoortheen.nix-ide # syntax and language support
      # arrterian.nix-env-selector
      
      # === python ===
      ms-python.python
      ms-python.vscode-pylance

      # === misc ===
      mkhl.direnv
      # tamasfe.even-better-toml
      # svelte.svelte-vscode
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # {
      #   name = "godot-tools";
      #   publisher = "geequlim";
      #   version = "2.1.0";
      #   sha256 = "sha256-/0D4IJQXcjVtmX5gLKfEvviTQM595Y0EzCxlmVnsnJw=";
      # }
    ];

  };

}



