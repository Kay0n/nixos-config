{ config, lib, pkgs, ... }:

let
  celestenet-dist = "${pkgs.fetchzip {
    url = "https://github.com/0x0ade/CelesteNet/releases/download/v2.4.1-server/CelesteNet.Server-2024-09-23_fixed.zip";
    sha256 = "sha256-/FPKd6pfGU+pSifPsCbF28eX1slFrj/c4yf02H2iW8E=";
    stripRoot = false;
  }}/net7.0";

  mainConfigContent = {
  };

  chatConfigContent = {
    MessageGreeting = "Hello World";
  };

  mainOverrides = pkgs.writeText "override-main.json" (builtins.toJSON mainConfigContent);
  chatOverrides = pkgs.writeText "override-chat.json" (builtins.toJSON chatConfigContent);

  dotnetBin = "${pkgs.dotnet-runtime_7}/bin/dotnet";
  serverDll = "${celestenet-dist}/CelesteNet.Server.dll";

in



{
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-7.0.20"
  ];

    networking.firewall.allowedTCPPorts = [ 
      17230 
    ];
    networking.firewall.allowedUDPPorts = [
      17230
    ];

  systemd.services.celestenet = {
    description = "CelesteNet Server";
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.yq-go pkgs.coreutils ];

    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "celestenet"; 
      WorkingDirectory = "/var/lib/celestenet";
      Restart = "always";
    };

    preStart = ''
      MAIN_CFG="celestenet-config.yaml"
      CHAT_CFG="ModuleConfigs/CelesteNet.Server.ChatModule.yaml"

      rm -rf Modules
      ln -sf "${celestenet-dist}/Modules" Modules

      rm -f "$MAIN_CFG"
      rm -f "$CHAT_CFG"

      # start server in bg to generate config files
      ${dotnetBin} ${serverDll} &
      SERVER_PID=$!

      # kill server in 10s or when configs exist
      for i in $(seq 1 1000); do
          if [ -f "$MAIN_CFG" ] && [ -f "$CHAT_CFG" ]; then
              break
          fi
          sleep 0.01
      done
      kill $SERVER_PID 2>/dev/null || true
      wait $SERVER_PID 2>/dev/null || true

      # patch configs
      yq -P -i ". *= load(\"${mainOverrides}\")" "$MAIN_CFG"
      yq -P -i ". *= load(\"${chatOverrides}\")" "$CHAT_CFG"

    '';

    script = ''
      exec ${dotnetBin} ${serverDll}
    '';
  };
}