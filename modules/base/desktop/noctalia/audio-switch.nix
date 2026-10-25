{ ... }:
{
  flake.modules.nixos.audio-switch = { pkgs, ... }: {

    # volume widget right click cycles the default output, skipping HDMI
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "audio-output-cycle";
        runtimeInputs = [ pkgs.pulseaudio ];
        text = ''
          mapfile -t sinks < <(pactl list short sinks | cut -f2 | grep -v hdmi)
          (( ''${#sinks[@]} > 1 )) || exit 0
          current=$(pactl get-default-sink)
          for i in "''${!sinks[@]}"; do
            if [[ ''${sinks[$i]} == "$current" ]]; then
              pactl set-default-sink "''${sinks[$(( (i + 1) % ''${#sinks[@]} ))]}"
              exit
            fi
          done
          pactl set-default-sink "''${sinks[0]}"
        '';
      })
    ];

  };
}
