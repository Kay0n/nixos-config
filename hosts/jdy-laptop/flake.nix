{
  description = "jdy-laptop NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; 
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    glaumar_repo = {
      url = "github:glaumar/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs: {
    nixosConfigurations.jdy-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        home-manager.nixosModules.home-manager 
        ./configuration.nix 
        ./hardware-configuration.nix
      ];
    };
  };
}
