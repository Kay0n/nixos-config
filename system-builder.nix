{home-manager, nixpkgs, systems, ...}:
let
  lib=nixpkgs.lib;


  # ------ Example System Definition ------
  #
  # systems = [
  #   {
  #     hostname = "hostname1";
  #     system = "x86_64-linux";
  #     users = [{
  #       name = "username";
  #       home-manager-imports = [ 
  #         ./users/<user>/main.nix 
  #       ];
  #     }];
  #     modules = [
  #       ./hosts/common.nix
  #     ];
  #   }

  #   {
  #     hostname = "hostname2";
  #     system = "aarch64_linux";
  #     users = [{
  #       name = "username";
  #       home-manager-imports = [ 
  #         ./users/<user>/main.nix 
  #       ];
  #     }];
  #     modules = [
  #       ./hosts/common.nix
  #     ];
  #   }
  # ];





  

  # function to convert a single system definition to a NixOS configuration
  mkNixosConfiguration = { hostname, system, users, modules }: 
    {
      inherit system;
      modules = modules ++ 
      [
        home-manager.nixosModules.home-manager 
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users = lib.genAttrs (map (user: user.name) users) (name: let
            user = lib.findFirst (u: u.name == name) null users;
          in 
          {
            imports = user.home-manager-imports;
          });
        }
      ];
    };

in
{
  # loops through list and generates a set of nixosConfigurations
  nixosConfigurations = lib.genAttrs (map (sys: sys.hostname) systems) (system:
    nixpkgs.lib.nixosSystem (mkNixosConfiguration (lib.findFirst (s: s.hostname == system) null systems))
  );
}




