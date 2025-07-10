{ pkgs, config, ... }:
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  services.xrdp.openFirewall = true;

  # userMapping = pkgs.writeText "user-mapping.xml"
  # ''
  #   <?xml version="1.0" encoding="UTF-8"?>
  #   <user-mapping>
  #       <!-- User using SHA-256 to hash the password -->
  #       <authorize
  #         username="kayon"
  #         password="0ca70b2b576d5932b96090836c46ddd48aa88ffa88f74e79b8efb89dfa964e5b"
  #         encoding="sha256"
  #       >
  #         <connection name="NixOS Server SSH">
  #             <protocol>ssh</protocol>
  #             <param name="hostname">127.0.0.1</param>
  #             <param name="port">22</param>
  #         </connection>

  #         <connection name="NixOS Server RDP">
  #             <protocol>rdp</protocol>
  #             <param name="hostname">127.0.0.1</param>
  #             <param name="port">3389</param>
  #             <param name="ignore-cert">true</param>
  #         </connection>
  #       </authorize>
  #   </user-mapping>
  # '';

  # services.guacamole-server = {
  #   enable = true;
  #   host = "127.0.0.1";
  #   # userMappingXml = ./user-mapping.xml;
  # };

  # services.guacamole-client = {
  #   enable = true;
  #   enableWebserver = true;
  #   settings = {
  #     guacd-port = 4822;
  #     guacd-hostname = "127.0.0.1";
  #   };
  # };

  networking.firewall.allowedTCPPorts = [ 
    # 8080 in main file
  ];

}


  
# 0ca70b2b576d5932b96090836c46ddd48aa88ffa88f74e79b8efb89dfa964e5b
# orangeresonance






