{
  description = "Kayon's nixos config";

  # input flakes that this flake will use
  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";  # stable - github:nixos/nixpkgs/nixos-23.11
    
    home-manager = {
      url = "github:nix-community/home-manager";          # stable - github:nix-community/home-manager/release-23.11
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


  # output, defines how system will use flake
  outputs = inputs@{ nixpkgs, home-manager, ... }: {

    nixosConfigurations = {

      jdy-laptop = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";

        modules = [
          ./hosts/laptop
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.kayon.imports = [./home.nix ];
          }
        ];
      };
    };
  };
}