{pkgs, ...}:
{
  security.sudo.extraRules = [
    {
      users = [ "kayon" ];
      commands = [
        {
          command = "ALL";
          options = [ "SETENV" "NOPASSWD" ];
        }
      ];
    }
  ]; 

  users.users.kayon = {
    isNormalUser = true;
    description = "Kayon";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    initialPassword = "password";
  };

  users.users.kayon.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChBt7qeIINoUS5KOZ1yXerPko6Gch8qR6XU8LIUxKbi5PwItAUzJ8HA1foZhCRvDutESO7tsqSn9OyFgRstuZmOVMGM6VGMmsPrfqVxF8YHojgnhfILWoQ6fT+t0jX+SHu3zxv1sVGrJJbykGa1Wemd9zRgEj55PkhoGlnMKyQmd6LBO1qRpW6ye0wX8ESFPlhN0UH/7GAo4SoiIz59rXlzQdEMYQH+LKMLJ97TBzf2M5eyIp8zYcWFCpO5c5E9cZm6W/iRBDe7b06Yx/5Qyda0obBqjdO64hGfl+km1dQJJi5fgxupcdg3uC2eNZIbDbDqrgf6tcwsIhuYeTbMdNTaiO+wfRLFspnFpsHMGsfSQD4wbf0sHmYR+EbA+VI/pD6rdk0JaKhc01fqTBDQP90GaxxMCTvFr3bIanLRx5S4WTWmRVMeIYUrYZhDidh05+KHiS9bHsaaWSXHbD6K1C1wk9E8QvLSi0a2Omt4FDgrfqJXDlPVPNj7m/B9JltpUs= kayon@pop-os"
  ];


}