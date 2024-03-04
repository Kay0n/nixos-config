{pkgs, ...}:
{

  # load user profile
  users.users.share = {
    isNormalUser = true;
    description = "Share";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # jdy-laptop id_ed25519.pub
  users.users.share.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2sHKCs0wHA8m5sDwaISRn7MzGgw4QnZtW1o9jyjfJi kayon@jdy-laptop"
  ];

}