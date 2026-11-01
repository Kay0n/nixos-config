{ homeManager, ... }:
{
  flake.modules.nixos.ghostty = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      ghostty
    ];

    programs.nautilus-open-any-terminal.terminal = "ghostty";

    home-manager.sharedModules = [ homeManager.ghostty ];

  };



  flake.modules.homeManager.ghostty = { pkgs, config, ... }: {

    home.file.".config/ghostty/config".source = config.lib.dotfiles.link ./ghostty.conf;

  };

}
