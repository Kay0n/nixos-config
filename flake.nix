{
  description = "Kayon's NixOS Configurations - Root Flake";

  inputs = {
    # jdy-laptop.url = "path:./hosts/jdy-laptop";
    # mv-church.url = "path:./hosts/mv-church";
    oracle-main.url = "path:./hosts/oracle-main";
    # jdy-desktop.url = "path:./hosts/jdy-desktop";
  };

  outputs = { self, ... }@inputs: {
    nixosConfigurations = {
      # jdy-laptop = inputs.jdy-laptop.nixosConfigurations.jdy-laptop;
      # mv-church = inputs.mv-church.nixosConfigurations.mv-church;
      oracle-main = inputs.oracle-main.nixosConfigurations.oracle-main;
      # jdy-desktop = inputs.jdy-desktop.nixosConfigurations.jdy-desktop;
    };
  };
}