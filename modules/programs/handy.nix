{ ... }:
{
  flake.modules.nixos.handy = { pkgs, ... }: let
    # handy forces WEBKIT_DISABLE_DMABUF_RENDERER=1, which conflicts with WebKitGTK 2.54
    # see https://github.com/cjpais/Handy/issues/2166
    handy = pkgs.handy.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src-tauri/src/main.rs \
          --replace-fail 'std::env::set_var("WEBKIT_DISABLE_DMABUF_RENDERER", "1");' ""
      '';
      preFixup = builtins.replaceStrings
        [ "--set WEBKIT_DISABLE_DMABUF_RENDERER 1" ] [ "" ]
        old.preFixup;
    });
  in {
    environment.systemPackages = [
      handy # global keybindings dont work, niri calls `handy --toggle-transcription` instead
      pkgs.wtype
    ];
  };
}
