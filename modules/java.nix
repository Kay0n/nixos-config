{ pkgs, ... }:

  # enable "java8" and "java17" to be used in shell
  let
    java8 = pkgs.writeShellScriptBin "java8" ''
      exec ${pkgs.jdk8}/bin/java "$@"
    '';
    java17 = pkgs.writeShellScriptBin "java17" ''
      exec ${pkgs.jdk17}/bin/java "$@"
    '';
    java25 = pkgs.writeShellScriptBin "java25" ''
      exec ${pkgs.jdk25}/bin/java "$@"
    '';
  in
  {
    programs.java = {
      enable = true;
      package = pkgs.jdk25;
    };

    environment.systemPackages = with pkgs; [
      java8 
      java17
      java25
      gradle
    ];
  }
