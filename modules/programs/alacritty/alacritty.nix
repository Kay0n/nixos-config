{ homeManager, ... }:
{
  flake.modules.nixos.alacritty = { pkgs, lib, ... }: {

    environment.systemPackages = with pkgs; [
      alacritty 
    ];

    programs.nautilus-open-any-terminal.terminal = lib.mkDefault "alacritty";

    home-manager.sharedModules = [ homeManager.alacritty ];

  };



  flake.modules.homeManager.alacritty = { pkgs, config, ... }: {

    home.file.".config/alacritty/alacritty.toml".source = config.lib.dotfiles.link ./alacritty.toml;

  };

}
