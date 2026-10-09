# Realtek ALC897: front headset jack and rear line out as separate sinks.
{ pkgs, ... }:
{
  services.pipewire = {
    # Pro Audio: one node per PCM. pro-output-0 = rear, pro-output-2 = front.
    wireplumber.extraConfig."51-alc897-split" = {
      "device.profile.priority.rules" = [{
        matches = [{ "device.name" = "alsa_card.pci-0000_15_00.6"; }];
        actions.update-props.priorities = [ "pro-audio" ];
      }];
      "monitor.alsa.rules" = [
        {
          matches = [{ "node.name" = "alsa_output.pci-0000_15_00.6.pro-output-0"; }];
          actions.update-props = {
            "node.description" = "Speakers";
            "node.nick" = "Speakers";
          };
        }
        {
          matches = [{ "node.name" = "alsa_output.pci-0000_15_00.6.pro-output-2"; }];
          actions.update-props = {
            "node.description" = "Headset";
            "node.nick" = "Headset";
          };
        }
        {
          matches = [{ "node.name" = "alsa_input.pci-0000_15_00.6.pro-input-0"; }];
          actions.update-props = {
            "node.description" = "Headset Mic";
            "node.nick" = "Headset Mic";
          };
        }
        {
          # unused second ADC
          matches = [{ "node.name" = "alsa_input.pci-0000_15_00.6.pro-input-2"; }];
          actions.update-props."node.disabled" = true;
        }
      ];
    };
  };

  # Codec hints:
  # - auto_mute = no: headset doesn't mute rear output
  # - indep_hp = yes: front jack gets own PCM (hw:X,2)
  # Passed to both cards (index order not fixed); [codec] limits it to ALC897.
  hardware.firmware = [
    (pkgs.writeTextDir "lib/firmware/alc897-split.fw" ''
      [codec]
      0x10ec0897 0x1462ee24 0

      [hint]
      auto_mute = no
      indep_hp = yes
    '')
  ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel patch=alc897-split.fw,alc897-split.fw
  '';

  # Pro Audio ignores hardware mixer: enable independent HP, unmute outputs.
  services.udev.extraRules =
    let
      setup = pkgs.writeShellScript "alc897-mixer-setup" ''
        amixer=${pkgs.alsa-utils}/bin/amixer
        $amixer -q -c "$1" sset 'Independent HP' Enabled
        for ctl in Master Front Headphone; do
          $amixer -q -c "$1" sset "$ctl" 100% unmute
        done
        $amixer -q -c "$1" sset 'Input Source' 'Front Mic'
      '';
    in
    ''
      ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC*", ATTRS{id}=="Generic", RUN+="${setup} %n"
    '';
}
