{ homeManager, ... }:
{

  flake.modules.nixos.noctalia = { pkgs, ... }: {


    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        cursor.size = 24;
        keyboard.layout = "us";
      };
      passwordlessSyncUsers = [ "kayon" ];
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };
    };

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      recommendedServices.enable = true;
    };

    services.upower.enable = true;

    home-manager.sharedModules = [ homeManager.noctalia ];


  };

  flake.modules.homeManager.noctalia = { pkgs, config, ... }: {
    home.file.".local/state/noctalia/settings.toml".source = config.lib.dotfiles.link ./noctalia-config.toml;
  };
}
