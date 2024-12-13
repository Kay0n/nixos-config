{ config, pkgs, ... }:

{

  networking.hostName = "mv-church";

  imports = [
    ../../modules/common.nix
    ../../users/kayon/system-load.nix
    ../../modules/java.nix
    ../../modules/dotnet.nix
  ];
  

  # user specific settings   
  home-manager.users.kayon = {
    imports = [
      ../../users/kayon
      ../../users/kayon/modules/tmux.nix
      ../../users/kayon/modules/git.nix
      ../../users/kayon/modules/zsh.nix
      
    ];

    home.packages = with pkgs; [
    ];
  };
  

  environment.systemPackages = with pkgs; [
  ];

  programs.zsh.enable = true;
 
  services.openssh.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = options.programs.nix-ld.libraries.default ++ (with pkgs; [ 
    icu
  ]);


  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    zone = "refract.online";
    use = "web";
    passwordFile = "/run/secrets/cloudflare-token";
    interval = "5min";
    domains = [
      "mv.refract.online"
    ];
    extraConfig = ''
      web='https://cloudflare.com/cdn-cgi/trace'
      web-skip='ip='
    '';
  };
  
  networking.firewall.allowedTCPPorts = [ 50000 50001 50002 50005 22 ];
  
  system.stateVersion = "23.11"; 

  
}
