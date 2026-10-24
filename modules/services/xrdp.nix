{ ... }:
{
  flake.modules.nixos.xrdp = { pkgs, config, ... }: {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = false;
    services.xserver.displayManager.startx.enable = true; 
    services.desktopManager.plasma6.enable = true;


    services.xrdp.enable = true;
    services.xrdp.defaultWindowManager = "startplasma-x11";
    services.xrdp.openFirewall = false;
    networking.firewall.interfaces.docker0.allowedTCPPorts = [ config.services.xrdp.port ];
    services.xrdp.extraConfDirCommands = ''
      substituteInPlace $out/xrdp.ini \
            --replace-fail "LogLevel=INFO" "LogLevel=ERROR" 
    '';

  };
}
