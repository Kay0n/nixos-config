{ pkgs, config, ... }:
{


  sops.templates."rclone.conf" = {
    owner = "kayon";
    content = ''
      [mv-google-drive]
      type = drive
      client_id = ${config.sops.placeholder.rclone_client_id}
      scope = drive
      client_secret = ${config.sops.placeholder.rclone_client_secret}
      token = ${config.sops.placeholder.rclone_access_token}
      team_drive =

      [secret]
      type = crypt
      remote = mv-google-drive:book-backup
      password = ${config.sops.placeholder.rclone_crypt_password}
    '';
  };



  systemd.services.rclone-book-backup = {
    description = "Rclone backup of book library to Enctypted Google Drive";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "kayon"; 

      ExecStart = ''
        ${pkgs.rclone}/bin/rclone sync \
          /home/kayon/book-automation/cwa/library \
          secret:book-backup \
          --config "${config.sops.templates."rclone.conf".path}" \
          --verbose
      '';
    };
  };



  systemd.timers.rclone-book-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "2d"; 
      Persistent = true;
    };
  };



  # ====== Mount Crpyt ======
  # rclone mount secret: ~/gdrive-books \
  #   --config /run/secrets/rendered/rclone.conf \
  #   --read-only \
  #   --vfs-cache-mode full

}



