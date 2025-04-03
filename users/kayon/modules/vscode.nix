
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
      # saoudrizwan.claude-dev # cline
      svelte.svelte-vscode
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "claude-dev";
        publisher = "saoudrizwan";
        version = "3.8.3";
        sha256 = "sha256-0FAxQ67AKcSbCp8vQr2KUOIRw8LEQ3TQyJkfJwtmdoY=";
      }
      {
        name = "remote-server";
        publisher = "ms-vscode";
        version = "1.6.2025010809";
        sha256 = "sha256-m9P8WFb3qYGF/oL4f6kHQSwd+YCc4vsx1XFhkiQE1B8=";
      }
      # {
      #   name = "godot-tools";
      #   publisher = "geequlim";
      #   version = "2.1.0";
      #   sha256 = "sha256-/0D4IJQXcjVtmX5gLKfEvviTQM595Y0EzCxlmVnsnJw=";
      # }

    ];

  };

}



