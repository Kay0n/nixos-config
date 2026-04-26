{ pkgs, inputs, ... }:




let
  llama-vulkan = (inputs.llama-cpp.packages.${pkgs.system}.vulkan).overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or []) ++ [
      "-DGGML_NATIVE=ON"
    ];
  });
in
let
  ai = pkgs.writeShellScriptBin "ai" ''
    ${llama-vulkan}/bin/llama-server \
      --models-dir ~/.cache/llama.cpp \
      --models-preset ~/.cache/llama.cpp/models.ini \
      --port 8033 \
      --host 127.0.0.1 \
      --jinja 
      -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_M




    echo "llama-server exited"
  '';

    ai-web = pkgs.writeShellScriptBin "ai-web" ''
    # open in background
    (${pkgs.xdg-utils}/bin/xdg-open http://localhost:8033 &) >/dev/null 2>&1       

    ai
  '';

  opencode-websearch = pkgs.writeShellScriptBin "opencode" ''
    export OPENCODE_ENABLE_EXA=1
    exec ${pkgs.opencode}/bin/opencode "$@"  
  '';
in


{
  nixpkgs.overlays = [ 
    inputs.llama-cpp.overlays.default
    (final: prev: {

      pi-coding-agent = prev.pi-coding-agent.overrideAttrs (new: old: {
        version = "0.70.0";
        src = old.src.override {
          hash = "sha256-gB3QUxA4OZ8Zg5YGbAHmknSnAHrhEGxzz/DXRiKiK50=";
        };
        # npmDepsHash = ""; # not needed if overriding npmDeps
        npmDeps = pkgs.fetchNpmDeps {
          inherit (new) src;
          hash = "sha256-SBm5GPmHNZ24zYBo3rA9n3XTz8Y7oNOaGJ2dY/X2ccw=";
        };
      });

    })
  ];



  environment.systemPackages = with pkgs; [
    ai
    ai-web
    opencode-websearch
    pi-coding-agent
    llama-vulkan
  ];

}