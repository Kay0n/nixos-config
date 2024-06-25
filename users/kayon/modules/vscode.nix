
{ pkgs, ... }: {

  programs.vscode = {
    enable = true;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      ms-vscode-remote.remote-ssh
      redhat.java
      vscjava.vscode-java-debug
      visualstudioexptteam.vscodeintellicode
      vscjava.vscode-maven
      vscjava.vscode-java-dependency
      vscjava.vscode-gradle
      arrterian.nix-env-selector
      mathiasfrohlich.kotlin
      ms-python.python
    ];

  };

}



