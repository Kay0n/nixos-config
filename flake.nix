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
      tb-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/tb-desktop
        ];
      };
    };
  };
}




  #   # more readable system definition
  #   systems = [
  #     {
  #       hostname = "jdy-laptop";
  #       system = "x86_64-linux";
  #       users = [{
  #         name = "kayon";
  #         home-manager-imports = [ 
  #           ./users/kayon/main.nix
  #           ./users/kayon/display.nix
  #         ];
  #       }];
  #       modules = [
  #         ./hosts/common.nix
  #         ./hosts/jdy-laptop/configuration.nix
  #         ./users/kayon/load.nix
  #       ];
  #     }
  #     {
  #       hostname = "oracle-main";
  #       system = "aarch64-linux";
  #       users = [{
  #         name = "kayon";
  #         home-manager-imports = [ ./users/kayon/main.nix ];
  #       }];
  #       modules = [
  #         ./hosts/common.nix
  #         ./hosts/oracle-main
  #         ./users/kayon/load.nix
  #         ./users/share/load.nix
  #       ];
  #     }
  #     {
  #       hostname = "jdy-desktop";
  #       system = "x86_64-linux";
  #       users = [{
  #         name = "kayon";
  #         home-manager-imports = [ ./users/kayon/main.nix ];
  #       }];
  #       modules = [
  #         ./hosts/common.nix
  #         ./hosts/jdy-desktop
  #         ./users/kayon/load.nix
  #       ];  
  #     }
  #     {
  #       hostname = "mv-church";
  #       system = "x86_64-linux";
  #       users = [{
  #         name = "kayon";
  #         home-manager-imports = [ ./users/kayon/main.nix ];
  #       }];
  #       modules = [
  #         ./hosts/common.nix
  #         ./hosts/mv-church
  #         ./users/kayon/load.nix
  #       ];  
  #     }
  #   ];
