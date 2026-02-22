{ pkgs, ... }:

{
  # ----- common -----

  home.username = "kayon";
  home.homeDirectory = "/home/kayon";

  # home-manager version, do not touch
  home.stateVersion = "23.11"; 
  
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
  ];
  


  

}