
{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    temurin-jre-bin-8
    temurin-jre-bin-17
  ];

  programs.java = {
    enable = true;
    package = pkgs.temurin-jre-bin-21;
  };

}



