{ pkgs, config, ... }:
{
  services.xserver.enable = true;
  # services.displayManager.sddm.enable = true; 
  services.desktopManager.plasma6.enable = true;

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  services.xrdp.openFirewall = true;
  services.xrdp.extraConfDirCommands = ''
    substituteInPlace $out/xrdp.ini \
          --replace "LogLevel=INFO" "LogLevel=ERROR" 
  '';

  networking.firewall.allowedTCPPorts = [ 
    # 8080 in main file
  ];

}


  
# 0ca70b2b576d5932b96090836c46ddd48aa88ffa88f74e79b8efb89dfa964e5b
# orangeresonance






