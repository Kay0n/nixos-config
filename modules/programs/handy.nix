{ ... }:
{
  flake.modules.nixos.handy = { pkgs, ... }: let
    # handy forces WEBKIT_DISABLE_DMABUF_RENDERER=1, which conflicts with WebKitGTK 2.54
    # see https://github.com/cjpais/Handy/issues/2166
    handy = pkgs.handy.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src-tauri/src/main.rs \
          --replace-fail 'std::env::set_var("WEBKIT_DISABLE_DMABUF_RENDERER", "1");' ""
        # --no-tray forces the window open even with --start-hidden.
        # not needed: launching `handy` again shows the window via single-instance
        substituteInPlace src-tauri/src/lib.rs \
          --replace-fail 'if should_force_show || !should_hide || !tray_available {' \
                         'if should_force_show || !should_hide {'
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
