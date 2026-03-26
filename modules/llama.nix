{ pkgs, ... }:

let
  llama = pkgs.writeShellScriptBin "llama" ''
    # open in background
    (${pkgs.xdg-utils}/bin/xdg-open http://localhost:8033 &) >/dev/null 2>&1       

    ${pkgs.llama-cpp-vulkan}/bin/llama-server \
      --models-dir ~/.cache/llama.cpp \
      --port 8033 \
      --host 127.0.0.1 \
      --jinja \
      -c 0 \
      --ctx-size 131072

    echo "llama-server exited"
  '';

  opencode-websearch = pkgs.writeShellScriptBin "opencode" ''
    export OPENCODE_ENABLE_EXA=1
    exec ${pkgs.opencode}/bin/opencode "$@"  
  '';
in


{
  nixpkgs.overlays = [
    (final: prev: {
      llama-cpp = (prev.llama-cpp.override {
        blasSupport = true;
      })
      .overrideAttrs (old: {
        version = "8508";

        src = old.src.override {
          hash = "sha256-73JfQWN/mPFV82Qod61AgxMpSrgh0Lz/NEsf1ljZHUc=";
        };

        npmDepsHash = "sha256-DxgUDVr+kwtW55C4b89Pl+j3u2ILmACcQOvOBjKWAKQ=";

        cmakeFlags = (old.cmakeFlags or []) ++ [
          "-DGGML_NATIVE=ON"
        ];

      });
    })
  ];



  environment.systemPackages = with pkgs; [
    llama
    opencode-websearch
  ];

}