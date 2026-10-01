{ homeManager, ... }:
{
  flake.modules.nixos.alacritty = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      alacritty 
    ];

    home-manager.sharedModules = [ homeManager.alacritty ];

  };



  flake.modules.homeManager.alacritty = { pkgs, config, ... }: {

    home.file.".config/alacritty/alacritty.toml".source = config.lib.dotfiles.link ./alacritty.toml;

  };

}
