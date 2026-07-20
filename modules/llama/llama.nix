{ pkgs, inputs, ... }:




let
  llama-vulkan =
    inputs.llama-cpp.packages.${pkgs.system}.vulkan.overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or []) ++ [
        "-DLLAMA_BUILD_TESTS=OFF"
        "-DLLAMA_BUILD_EXAMPLES=OFF"
        "-DLLAMA_BUILD_WEBUI=OFF"
        "-DLLAMA_BUILD_UI=OFF"
      ];
    });
in


let
  ai = pkgs.writeShellScriptBin "ai" ''
    ${llama-vulkan}/bin/llama-server \
      --models-dir ~/.cache/llama.cpp \
      --models-preset ~/.cache/llama.cpp/models.ini \
      --port 8033 \
      --host 127.0.0.1
  '';

  opencode-websearch = pkgs.writeShellScriptBin "opencode" ''
    export OPENCODE_ENABLE_EXA=1
    exec ${pkgs.opencode}/bin/opencode "$@"  
  '';
in


{
  nixpkgs.overlays = [ 
    inputs.llama-cpp.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    ai
    opencode-websearch
    pi-coding-agent
    llama-vulkan
  ];

  home-manager.users.kayon = {config, ...}: {
    home.file.".cache/llama.cpp/models.ini".source = config.lib.file.mkOutOfStoreSymlink "/home/kayon/.nixos-config/modules/llama/models.ini";
  };
}


# donwload HF models with `llama-cli -hf <model-name>`
# name example: `unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_M`
