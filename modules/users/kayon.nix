{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.kayon =
    { pkgs, ... }:
    {
      imports = [ nixos.home-manager ];

      # load user profile
      users.users.kayon = {
        isNormalUser = true;
        description = "Kayon";
        extraGroups = [ "networkmanager" "wheel" "docker"];
        shell = pkgs.zsh;
        initialPassword = "password"; # CHANGE WHEN USING
      };


      # ssh keys
      users.users.kayon.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2sHKCs0wHA8m5sDwaISRn7MzGgw4QnZtW1o9jyjfJi kayon@jdy-laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPooq+g0v2DYEvw4WglL571tA7fzV/E+VsijzIqFE7md kayon@jdy-desktop"
      ];

      # user doesn't have to type password for sudo
      security.sudo.extraRules = [
        {
          users = [ "kayon" ];
          commands = [
            {
              command = "ALL";
              options = [ "SETENV" "NOPASSWD" ];
            }
          ];
        }
      ]; 

      # enable zsh.enableAutosuggestions to work on non-home-manager installed pkgs
      environment.pathsToLink = [ "/share/zsh" ];     
      programs.zsh.enable = true;

      # home-manager profile, add per-host home features with
      # `home-manager.users.kayon.imports = [ homeManager.<feature> ];`
      home-manager.users.kayon.imports = [ homeManager.kayon ];
    };

  # home-manager config common to every host
  flake.modules.homeManager.kayon = {
    imports = with homeManager; [
      git
      tmux
      zsh
    ];

    home.username = "kayon";
    home.homeDirectory = "/home/kayon";

    # home-manager version, do not touch
    home.stateVersion = "23.11"; 

    programs.home-manager.enable = true;
  };
}
