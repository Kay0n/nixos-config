{ pkgs, config, ... }:
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = false;
  services.xserver.displayManager.startx.enable = true; 
  services.desktopManager.plasma6.enable = true;

  
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  services.xrdp.openFirewall = true;
  services.xrdp.extraConfDirCommands = ''
    substituteInPlace $out/xrdp.ini \
          --replace "LogLevel=INFO" "LogLevel=ERROR" 
  '';

}









