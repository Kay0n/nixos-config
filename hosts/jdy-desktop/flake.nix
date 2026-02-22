{
  description = "jdy-desktop NixOS Config";

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
    glaumar_repo = {
      url = "github:glaumar/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    self, 
    nixpkgs, 
    home-manager, 
    sops-nix, 
    nix-flatpak, 
    glaumar_repo, 
    ... 
   }@inputs: {
    
    nixosConfigurations.jdy-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [

        ({
          nixpkgs.overlays = [
            (final: prev: {
              glaumar_repo = inputs.glaumar_repo.packages."${prev.system}";
            })
          ];
        })

        home-manager.nixosModules.home-manager 
        nix-flatpak.nixosModules.nix-flatpak
        sops-nix.nixosModules.sops
        ./configuration.nix 
        ./hardware-configuration.nix
      ];
    };
  };
}
