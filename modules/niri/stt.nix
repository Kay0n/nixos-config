{pkgs, ...}:
# Source from https://code.m3ta.dev/m3tam3re/nixpkgs/src/branch/master/pkgs/stt-ptt/default.nix

let
  sttPtt = pkgs.writeShellScriptBin "stt-ptt" ''
    #!/usr/bin/env bash
    # stt-ptt - Push to Talk Speech to Text

    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/stt-ptt"
    MODEL_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/stt-ptt/models"
    AUDIO="$CACHE_DIR/stt.wav"

    # Configurable via environment
    STT_MODEL="''${STT_MODEL:-$MODEL_DIR/ggml-large-v3-turbo.bin}"
    STT_LANGUAGE="''${STT_LANGUAGE:-auto}"
    STT_NOTIFY_TIMEOUT="''${STT_NOTIFY_TIMEOUT:-3000}"

    NOTIFY="${pkgs.libnotify}/bin/notify-send"
    PW_RECORD="${pkgs.pipewire}/bin/pw-record"
    WHISPER="${pkgs.whisper-cpp-vulkan}/bin/whisper-cli"
    WTYPE="${pkgs.wtype}/bin/wtype"
    PKILL="${pkgs.procps}/bin/pkill"
    MKDIR="${pkgs.busybox}/bin/mkdir"
    RM="${pkgs.busybox}/bin/rm"
    TR="${pkgs.busybox}/bin/tr"
    SED="${pkgs.busybox}/bin/sed"
    SLEEP="${pkgs.busybox}/bin/sleep"

    # Ensure cache directory exists
    "$MKDIR" -p "$CACHE_DIR"

    # Kill any existing pw-record for this audio file (prevents orphan nodes)
    kill_existing() {
        "$PKILL" -f "pw-record.*$AUDIO" 2>/dev/null
        "$SLEEP" 0.1
    }

    case "''${1:-}" in
        start)
            kill_existing
            "$RM" -f "$AUDIO"
            "$NOTIFY" -t "$STT_NOTIFY_TIMEOUT" -a "stt-ptt" "Recording..."
            "$PW_RECORD" --rate=16000 --channels=1 "$AUDIO" &
            ;;
        stop)
            kill_existing

            if [[ -f "$AUDIO" ]]; then
                if [[ ! -f "$STT_MODEL" ]]; then
                    "$NOTIFY" -t "$STT_NOTIFY_TIMEOUT" -a "stt-ptt" "Error: Model not found at $STT_MODEL"
                    "$RM" -f "$AUDIO"
                    exit 1
                fi
                text=$("$WHISPER" -m "$STT_MODEL" -f "$AUDIO" -l "$STT_LANGUAGE" -np -nt 2>/dev/null | "$TR" -d '\n' | "$SED" 's/^[[:space:]]*//;s/[[:space:]]*$//')
                "$RM" -f "$AUDIO"
                [[ -n "$text" ]] && "$WTYPE" -- "$text"
            fi
            ;;
        *)
            echo "Usage: stt-ptt {start|stop}"
            echo ""
            echo "Environment variables:"
            echo "  STT_MODEL          - Path to whisper model (default: \$XDG_DATA_HOME/stt-ptt/models/ggml-large-v3-turbo.bin)"
            echo "  STT_LANGUAGE       - Language code or 'auto' for auto-detection (default: auto)"
            echo "  STT_NOTIFY_TIMEOUT - Notification timeout in ms (default: 3000)"
            exit 1
            ;;
    esac
  '';


  sttToggle = pkgs.writeShellScriptBin "stt-toggle" ''
    #!/usr/bin/env bash

    STT_TOGGLE_STATE_FILE="$HOME/.local/share/stt-ptt/toggle-state"

    mkdir -p "$(dirname "$STT_TOGGLE_STATE_FILE")"

    if [[ -f "$STT_TOGGLE_STATE_FILE" ]]; then
        # Currently recording -> stop
        ${sttPtt}/bin/stt-ptt stop
        rm -f "$STT_TOGGLE_STATE_FILE"
    else
        # Not recording -> start
        ${sttPtt}/bin/stt-ptt start
        touch "$STT_TOGGLE_STATE_FILE"
    fi
  '';
in


{
  environment.systemPackages = with pkgs; [
    sttPtt
    sttToggle
  ];
}