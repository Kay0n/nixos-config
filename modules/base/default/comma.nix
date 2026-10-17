{ inputs, ... }:
{
  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # prebuilt nix-index database (command-not-found, `nix-locate`)
  flake.modules.nixos.comma = {
    imports = [ inputs.nix-index-database.nixosModules.default ];

    programs.nix-index-database.comma.enable = true;

  };
}
