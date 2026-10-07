{ nixos, ... }:
{
  flake.modules.nixos."hosts/verbatim" = { config, lib, pkgs, ... }: {

    networking.hostName = "verbatim";


    imports = with nixos; [
      ./_hardware-configuration.nix

      default
      desktop
      niri
      noctalia
      kayon

      firefox
      vscode
      alacritty

      # services
      syncthing
      
    ];



    environment.systemPackages = with pkgs; [
      claude-code
    ];


    # USB killswitch on disconnect. Busybox in tmpfs, udev runs kernel-level reboot via `sysrq 'b'`
    systemd.tmpfiles.rules = [
      "d /run/usb-killswitch 0700 root root -"
      "C /run/usb-killswitch/busybox 0700 root root - ${pkgs.pkgsStatic.busybox}/bin/busybox"
    ];
    services.udev.extraRules = ''
      ACTION=="remove", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="${lib.removePrefix "/dev/disk/by-uuid/" config.fileSystems."/".device}", RUN{program}+="/run/usb-killswitch/busybox sh -c 'echo b > /proc/sysrq-trigger'"
    '';


    networking.firewall.allowedTCPPorts = [
      22 # ssh
    ];


  };
}
