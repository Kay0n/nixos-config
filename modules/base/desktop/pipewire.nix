{ ... }:
{
  flake.modules.nixos.pipewire = { pkgs, ... }: {

    services.pulseaudio.enable = false;
    security.rtkit.enable = true; # rtkit is optional but recommended
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true;
      # wireplumber.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # pavucontrol
      # pulseaudio
      # alsa-utils
      # alsa-tools
      # qpwgraph
    ];

    virtualisation.spiceUSBRedirection.enable = true;
  };
}
