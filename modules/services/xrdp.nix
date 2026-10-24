{ ... }:
{
  flake.modules.nixos.xrdp = { pkgs, config, ... }: {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = false;
    services.xserver.displayManager.startx.enable = true; 
    services.xserver.desktopManager.xfce.enable = true;


    services.xrdp.enable = true;
    services.xrdp.defaultWindowManager = "xfce4-session";
    services.xrdp.openFirewall = false;
    networking.firewall.interfaces.docker0.allowedTCPPorts = [ config.services.xrdp.port ];
    services.xrdp.extraConfDirCommands = ''
      substituteInPlace $out/xrdp.ini \
            --replace-fail "LogLevel=INFO" "LogLevel=ERROR" 
    '';

  };
}
