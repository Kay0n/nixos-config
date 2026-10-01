{ inputs, lib, ... }:
let
  # where this repo is checked out on disk
  repoPath = "/home/kayon/.nixos-config";
in
{
  # Loaded for every home-manager user (see modules/default/home-manager.nix).
  #
  # `config.lib.dotfiles.link ./foo.conf` symlinks a file in this repo into $HOME, editable in
  # place (not a read-only store copy). The path literal is next to the calling module; its
  # location inside the repo is derived from the flake source, so moving files can't break the link.
  #   xdg.configFile."foo".source = config.lib.dotfiles.link ./foo.conf;
  flake.modules.homeManager.dotfiles = { config, ... }: {
    lib.dotfiles.link =
      path:
      let
        src = "${toString inputs.self}/";
        file = toString path;
      in
      assert lib.assertMsg (lib.hasPrefix src file) "dotfiles.link: ${file} is not inside the flake";
      config.lib.file.mkOutOfStoreSymlink "${repoPath}/${lib.removePrefix src file}";
  };
}
