{
  description = "Kayon's NixOS Config";

  # Define input flakes that this flake will use
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; 
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, sops-nix, ... } @ inputs: {
    nixosConfigurations = {
      jdy-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/jdy-laptop
        ];
      };
      mv-church = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/mv-church
        ];
      };
      oracle-main = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/oracle-main
        ];
      };
      jdy-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/jdy-desktop
        ];
      };
    };
  };
}



# nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --flake .#oracle-main --target-host root@refract.online