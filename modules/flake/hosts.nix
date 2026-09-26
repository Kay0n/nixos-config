{
  inputs,
  config,
  lib,
  ...
}:
let
  # every `flake.modules.nixos."hosts/<name>"` becomes `nixosConfigurations.<name>`
  hostPrefix = "hosts/";
  hosts = lib.filterAttrs (name: _: lib.hasPrefix hostPrefix name) config.flake.modules.nixos;
in
{
  flake.nixosConfigurations = lib.mapAttrs' (
    name: module:
    lib.nameValuePair (lib.removePrefix hostPrefix name) (
      inputs.nixpkgs.lib.nixosSystem {
        modules = [ module ];
      }
    )
  ) hosts;
}
