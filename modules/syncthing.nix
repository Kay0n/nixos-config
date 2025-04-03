{ pkgs, ... }: {


  services.syncthing = {
    # web UI at 8384
    enable = true;
    user = "kayon";
    group = "users";
    dataDir = "/home/kayon";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      
      devices = {
        "jdy-desktop" = { id = "JIMQ75S-RWRJ4XZ-L2ILZXN-FSEIOL2-OJY2J4P-ZJ72XOQ-6NFOJRW-EQ3TCA7"; };
        "oracle-main" = { id = "DEVICE-ID-GOES-HERE"; };
        "jdy-samsung" = { id = "Y7224Y7-NQW7NB5-H74YYVA-KG5DHI4-MVAWMMG-INMA4J3-HYVH5RW-4SBPUQ2"; };
      };

      folders = {
        "Documents" = {
          id = "docs";
          path = "/home/kayon/Documents";
          devices = [ 
            "jdy-desktop" 
            "jdy-samsung" 
            "oracle-main" 
          ];
        };
      };

    };
    guiAddress = "0.0.0.0:50000"

  };

}



