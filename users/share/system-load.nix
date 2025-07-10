{ lib, pkgs, ...}:
{

  # load user profile
  users.users.share = { # remember to set password with `sudo passwd share`
    isNormalUser = true;
    description = "share user for ssh tunneling";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # ssh keys
  users.users.share.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2sHKCs0wHA8m5sDwaISRn7MzGgw4QnZtW1o9jyjfJi kayon@jdy-laptop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPooq+g0v2DYEvw4WglL571tA7fzV/E+VsijzIqFE7md kayon@jdy-desktop"
  ];

  services.openssh = {
    enable = true;
    extraConfig = ''
    Match User                    share
      PubkeyAuthentication        yes
      PasswordAuthentication      yes
      PermitEmptyPasswords        no
      GatewayPorts                yes
      AllowTcpForwarding          yes
      ClientAliveInterval         20
      ClientAliveCountMax         5
      HostbasedAuthentication     no
      RhostsRSAAuthentication     no
      AllowAgentForwarding        no
      X11Forwarding               no
      ForceCommand                ${lib.getExe' pkgs.coreutils-full "false"}
      Banner                      none
    '';
  };

}