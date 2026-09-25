{ pkgs, config, ... }:
{


  sops.templates."rclone-immich.conf" = {
    owner = "immich";
    content = ''
      [mv-google-drive]
      type = drive
      client_id = ${config.sops.placeholder.rclone_client_id}
      scope = drive
      client_secret = ${config.sops.placeholder.rclone_client_secret}
      token = ${config.sops.placeholder.rclone_access_token}
      team_drive =

      [immich-library]
      type = crypt
      remote = mv-google-drive:immich
      password = ${config.sops.placeholder.rclone_crypt_immich_pass}
    '';
  };


  systemd.services.rclone-immich = {
    description = "Mount encrypted Google Drive for Immich";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ "/run/wrappers" ];
    serviceConfig = {
      Type = "notify";
      User = "immich";
      Group = "immich";
      ExecStartPre = "${pkgs.coreutils}/bin/install -m 600 -o immich -g immich ${config.sops.templates."rclone-immich.conf".path} /run/rclone-immich/rclone.conf";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          immich-library: \
          /mnt/rclone-immich-media \
          --config /run/rclone-immich/rclone.conf \
          --allow-other \
          --cache-dir /var/cache/rclone \
          --vfs-cache-mode full \
          --vfs-cache-max-size 30G \
          --vfs-cache-max-age 168h \
          --vfs-read-chunk-size 128M
          --vfs-read-chunk-size-limit 2G
          --vfs-read-ahead 128M \
          --buffer-size 64M
          --dir-cache-time 1000h \
          --poll-interval 1m
      '';   
      ExecStop = "/run/wrappers/bin/fusermount3 -u /mnt/rclone-immich-media";
      Restart = "always";
      RestartSec = "10s";
    };
  };


  systemd.services.immich = {
    requires = [ "rclone-immich.service" ];
    after = [ "rclone-immich.service" ];
    wantedBy = [ "multi-user.target" ];
  };


  systemd.tmpfiles.rules = [
    "d /var/cache/rclone 0755 immich immich -"
    "Z /var/cache/rclone 0755 immich immich -"
    "d /mnt/rclone-immich-media 0755 immich immich -"
    "d /run/rclone-immich 0700 immich immich -"
  ];


  programs.fuse.userAllowOther = true;




}
