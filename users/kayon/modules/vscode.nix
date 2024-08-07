
{ pkgs, ... }: {

  programs.vscode = {
    enable = true;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      # base
      ms-vscode-remote.remote-ssh
      visualstudioexptteam.vscodeintellicode

      # java
      redhat.java
      vscjava.vscode-java-debug
      vscjava.vscode-maven
      vscjava.vscode-java-dependency
      vscjava.vscode-gradle
      mathiasfrohlich.kotlin

      #nix
      jnoortheen.nix-ide
      arrterian.nix-env-selector
      
      # python
      ms-python.python
      ms-python.vscode-pylance

      # misc
      tamasfe.even-better-toml
      ms-vsliveshare.vsliveshare
    ];

  };

}



