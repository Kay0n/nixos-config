{ pkgs, config, ... }:
{

  imports = [
    ./rclone.nix
  ];

  services.immich = {
    enable = true;
    mediaLocation = "/mnt/rclone-immich-media";
    host = "127.0.0.1";
    port = 2283; # default, for visability
    environment = {
      TZ = "Australia/Adelaide";
    };
  };



}





# ./immich-go upload from-google-photos --server=https://photos.refract.online --concurrent-tasks=1 --on-errors=4 --api-key=XXX --pause-immich-jobs=FALSE ./google-takeout.zip