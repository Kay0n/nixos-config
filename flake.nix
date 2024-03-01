{
  description = "Kayon's NixOS Config";

  # input flakes that this flake will use
  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; 
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


  outputs = {nixpkgs, home-manager, ... }@inputs: let

    # more readable system definition (at least to me)
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
          ./hosts/common.nix
          ./hosts/jdy-laptop
          ./users/kayon/load.nix
        ];
      }

      {
        hostname = "oracle-main";
        system = "aarch64_linux";
        users = [{
          name = "kayon";
          home-manager-imports = [ ./users/kayon/main.nix ];
        }];
        modules = [
          ./hosts/common.nix
          ./hosts/oracle-main
          ./users/kayon.nix
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
    