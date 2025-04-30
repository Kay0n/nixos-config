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
        "oracle-main" = { id = "QGSXIVA-3JQP6G5-D25L2BP-AD4J5N5-T7H6BQZ-TZUFFJO-HO6KAJV-YT2KMAJ"; };
        "jdy-samsung" = { id = "Y7224Y7-NQW7NB5-H74YYVA-KG5DHI4-MVAWMMG-INMA4J3-HYVH5RW-4SBPUQ2"; };
        "jdy-laptop" = { id = "SIAZJVL-VTIHLLW-6INP5DI-LNFDZIR-FX3XXJM-UWH45UV-A4IQYO3-BPMLIQ3"; };
      };

      folders = {
        "Documents" = {
          id = "docs";
          path = "/home/kayon/Documents";
          devices = [ 
            "jdy-desktop" 
            "jdy-samsung" 
            "oracle-main" 
            "jdy-laptop"
          ];
        };
        "congealed-magma" = {
          id = "obsidian-vault";
          path = "/home/kayon/congealed-magma";
          devices = [ 
            "jdy-desktop" 
            "jdy-samsung" 
            "oracle-main" 
            "jdy-laptop"
          ];
        };
        "nixos-config" = {
          id = "nixos-config";
          path = "/home/kayon/.nixos-config";
          devices = [ 
            "jdy-desktop" 
            "jdy-samsung" 
            "oracle-main" 
            "jdy-laptop"
          ];
        };
      };

    };

  };

}



