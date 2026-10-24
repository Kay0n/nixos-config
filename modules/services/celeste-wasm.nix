{ inputs, ... }:
{
  flake-file.inputs.celeste-wasm = {
    url = "github:Kay0n/celeste-wasm";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixos.celeste-wasm = { ... }: {
    imports = [ inputs.celeste-wasm.nixosModules.default ];

    services.celeste-wasm = {
      enable = false;
      # celeste.tar.gz lives here, must be accessable by all users
      archiveDir = "/var/lib/celeste-wasm"; 
    };
    
  };
}