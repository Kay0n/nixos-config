{
  description = "jdy-desktop NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; 
    nixpkgs-temp.url = "github:nixos/nixpkgs/nixos-unstable"; 

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
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llama-cpp.url = "github:ggml-org/llama.cpp";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

    omnibin =  {
      url = "github:fzakaria/omnibin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { 
    self, 
    nixpkgs, 
    nixpkgs-temp,
    home-manager, 
    sops-nix, 
    nix-flatpak, 
    glaumar_repo, 
    nix-index-database,
    llama-cpp,
    omnibin,
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
            (final: prev: {
              temp = import nixpkgs-temp {
                inherit (final) config;
                inherit (final.stdenv.hostPlatform) system;
              };
            })
          ];
        })

        home-manager.nixosModules.home-manager 
        nix-flatpak.nixosModules.nix-flatpak
        sops-nix.nixosModules.sops
        nix-index-database.nixosModules.default
        ./configuration.nix 
        ./hardware-configuration.nix
      ];
    };
  };
}
