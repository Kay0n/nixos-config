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
  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {


      jdy-laptop = nixpkgs.lib.nixosSystem {

        # extraSpecialArgs = {inherit inputs;};
        system = "x86_64-linux";

        modules = [
          ./hosts/laptop
          ./hosts/common

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.kayon.imports = [
              ./home/home.nix 
            ];
          }
        ];
      };


      # mv-church = nixpkgs.lib.nixosSystem {

      #   extraSpecialArgs = {inherit inputs;};
      #   system = "x86_64-linux";

      #   modules = [
      #     # ./hosts/laptop
      #     inputs.home-manager.nixosModules
      #     home-manager.nixosModules.home-manager
      #     {
      #       home-manager.useGlobalPkgs = true;
      #       home-manager.useUserPackages = true;
      #       home-manager.users = {
      #         kayon.imports = [./home.nix ];
      #       };
      #     }
      #   ];
      # };


      # oracle-main = nixpkgs.lib.nixosSystem {

      #   extraSpecialArgs = {inherit inputs;};
      #   system = "aarch64-linux";

      #   modules = [
      #     # ./hosts/laptop
      #     inputs.home-manager.nixosModules
      #     home-manager.nixosModules.home-manager
      #     {
      #       home-manager.useGlobalPkgs = true;
      #       home-manager.useUserPackages = true;
      #       home-manager.users = {
      #         kayon.imports = [./home.nix ];
      #       };
      #     }
      #   ];
      # };



    };
  };
}


