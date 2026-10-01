{ nixos, ... }:
{
  # settings shared by every desktop host
  flake.modules.nixos.desktop = { pkgs, ... }: {

    imports = with nixos; [
      pipewire
      niri
      noctalia
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.printing.enable = true;

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


  };
}
