
{ pkgs, ... }: {

  services.pulseaudio.enable = false;
  security.rtkit.enable = true; # rtkit is optional but recommended
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    # wireplumber.enable = true;
  #   extraConfig.pipewire."10-separate-outputs"."context.objects" = [
  #     {
  #       factory = "adapter";
  #       args = {
  #         "node.name" = "Headphones";
  #         "media.class" = "Audio/Sink";
  #         "audio.channels" = 2;
  #         "audio.position" = "Fl,FR";
  #         "ports" = {
  #           "lineout" = {
  #             "audio.port.name" = "analog-output-lineout";
  #           };
  #         };
  #       };
  #     }
  #     {
  #       factory = "adapter";
  #       args = {
  #         "node.name" = "Speakers";
  #         "media.class" = "Audio/Sink";
  #         "audio.channels" = 2;
  #         "audio.position" = "Fl,FR";
  #         "ports" = {
  #           "lineout" = {
  #             "audio.port.name" = "analog-output-lineout";
  #           };
  #         };
  #       };
  #     }
  #   ];

    
  };
#   pw-link Headphones:out alsa_output.pci-0000_15_00.6.analog-stereo:1

# pw-link Speakers:out alsa_output.pci-0000_15_00.6.analog-stereo:0
  

  # systemd.services.disable-auto-mute = {
  #   description = "Disable auto-mute on Realtek sound card";
  #   after = [ "sound.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.alsa-utils}/bin/amixer -c 1 sset 'Auto-Mute Mode' Disabled";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  boot.extraModprobeConfig = ''
    options snd_hda_intel model=alc897
  '';

  environment.systemPackages = with pkgs; [
    pavucontrol
    # pulseaudio
    # alsa-utils
    # alsa-tools
    # qpwgraph
  ];

  virtualisation.spiceUSBRedirection.enable = true;
}



