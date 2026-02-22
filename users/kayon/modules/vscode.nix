
{ pkgs, ... }: {

  programs.vscode = {
    enable = true;
    # enableUpdateCheck = false;
    # enableExtensionUpdateCheck = false;
    # mutableExtensionsDir = true;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [
      rustup 
      zlib 
      openssl.dev 
      pkg-config 
    ]);

    # profiles.default.userSettings = {
    #   "option.name" = "value";
    # }

    profiles.default.extensions = with pkgs.vscode-extensions; [
      # === base ===
      # ms-vscode-remote.remote-ssh
      visualstudioexptteam.vscodeintellicode

      # === java extensions ===
      redhat.java
      vscjava.vscode-java-debug
      vscjava.vscode-maven
      vscjava.vscode-java-dependency
      vscjava.vscode-gradle


      # === nix === 
      jnoortheen.nix-ide # syntax and language support
      arrterian.nix-env-selector
      
      # === python ===
      # ms-python.python # build fail as of 28-8-25
      # ms-python.vscode-pylance
      # ms-python.debugpy

      # === misc ===
      # rust-lang.rust-analyzer
      # mkhl.direnv

      # saoudrizwan.claude-dev # cline
      # svelte.svelte-vscode
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # {
      #   name = "remote-server"; # code tunnels
      #   publisher = "ms-vscode";
      #   version = "1.6.2025010809";
      #   sha256 = "sha256-m9P8WFb3qYGF/oL4f6kHQSwd+YCc4vsx1XFhkiQE1B8=";
      # }
      {
        name = "theme-vsmonokai";
        publisher = "lunadevel";
        version = "0.2.0";
        sha256 = "sha256-yRMrKsqmSQqnyhm/3079tw9HKVwgBmiBXi262YBoAoI=";
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



