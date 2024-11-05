{ lib, pkgs, ...}:
{

  # load user profile
  users.users.share = {
    isNormalUser = true;
    description = "share user for ssh tunneling";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # jdy-laptop id_ed25519.pub
  users.users.share.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2sHKCs0wHA8m5sDwaISRn7MzGgw4QnZtW1o9jyjfJi kayon@jdy-laptop"
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
      HostbasedAuthentication     no
      RhostsRSAAuthentication     no
      AllowAgentForwarding        no
      X11Forwarding               no
      ForceCommand                ${lib.getExe' pkgs.coreutils-full "false"}
      Banner                      none
    '';
  };

}