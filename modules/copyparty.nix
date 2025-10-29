{ pkgs, config, inputs, ...}: 
{
  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  # see `copyparty --help-flags` for available options
  services.copyparty = {
    enable = true;
    user = "kayon"; 
    # group = "copyparty"; 

    
    settings = {
      i = "0.0.0.0";
      # use lists to set multiple values
      # p = [ 3210 3211 ];
      # use booleans to set binary flags
      # no-reload = true;
      # using 'false' will do nothing and omit the value when generating a config
      ignored-flag = false;
    };

    accounts = {
      kayon = {
        passwordFile = "${config.sops.secrets."copyparty_pass".path}";
      };
    };

    volumes = {
      "/" = {
        # share the contents of "/srv/copyparty"
        path = "/home/kayon/www";
        # see `copyparty --help-accounts` for available options
        access = {
          # everyone gets read-access, but
          r = "*";
          # users "ed" and "k" get read-write
          "rwmda." = [ "kayon" ];
        };
      };
    };

  };
}