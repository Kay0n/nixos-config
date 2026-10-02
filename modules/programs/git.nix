{ ... }:
{
  flake.modules.homeManager.git = { ... }: {

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Kay0n";
          email = "kayon5555@gmail.com";
        };
      };
      signing.format = null;
    };

  };
}
