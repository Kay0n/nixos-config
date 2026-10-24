{ nixos, ... }:
{
  # settings shared by every desktop host
  flake.modules.nixos.desktop = { pkgs, ... }: {

    imports = with nixos; [
      pipewire
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.printing.enable = true;

    # firmware updates from LVFS
    # `fwupdmgr get-devices`   list visible devices
    # `fwupdmgr get-updates`   list available updates
    # `fwupdmgr update`        install
    services.fwupd.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true; # show battery charge on supported devices?
          FastConnectable = true;
          ControllerMode = "dual"; # support both classic and BLE devices
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "alacritty";
    };

  };
}
