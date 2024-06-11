{ pkgs, ... }:

  # enable "java8" and "java17" to be used in shell
  let
    java8 = pkgs.writeShellScriptBin "java8" ''
      exec ${pkgs.temurin-jre-bin-8}/bin/java "$@"
    '';
    java17 = pkgs.writeShellScriptBin "java17" ''
      exec ${pkgs.temurin-jre-bin-17}/bin/java "$@"
    '';
  in
  {
    environment.systemPackages = with pkgs; [
      temurin-jre-bin-21
      temurin-jre-bin-8
      temurin-jre-bin-17
      java8 
      java17
    ];
  }
