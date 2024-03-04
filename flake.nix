{
  description = "Kayon's NixOS Config";

  # define input flakes that this flake will use
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


  outputs = {nixpkgs, home-manager, sops-nix, ... }@inputs: let

    # more readable system definition
    systems = [
      {
        hostname = "jdy-laptop";
        system = "x86_64-linux";
        users = [{
          name = "kayon";
          home-manager-imports = [ 
            ./users/kayon/main.nix
            ./users/kayon/display.nix
          ];
        }];
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/common.nix
          ./hosts/jdy-laptop
          ./users/kayon/load.nix
        ];
      }

      {
        hostname = "oracle-main";
        system = "aarch64-linux";
        users = [{
          name = "kayon";
          home-manager-imports = [ ./users/kayon/main.nix ];
        }];
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/common.nix
          ./hosts/oracle-main
          ./users/kayon.nix
        ];
      }
      {
        hostname = "mv-church";
        system = "x86_64-linux";
        users = [{
          name = "kayon";
          home-manager-imports = [ 
            ./users/kayon/main.nix
          ];
        }];
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/common.nix
          ./hosts/mv-church
          ./users/kayon/load.nix
        ];
      }
    ];




  # build systems derevation
  in {
    nixosConfigurations = (import ./system-builder.nix { 
      inherit nixpkgs home-manager; 
      systems=systems; 
    }).nixosConfigurations;
  };





}
    