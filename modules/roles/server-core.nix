{ config, pkgs, lib, subnets, ... }:

{
  imports = [
    ../features/monitoring.nix
    ../features/node-exporter.nix
  ];

  networking.defaultGateway = "${subnets.lan}.1";
  networking.nameservers = [ "${subnets.lan}.1" ];
  networking.defaultGateway.interface = "eno1";

  networking.enableIPv6 = false;

  networking.networkmanager.enable = false;
  networking.useDHCP = false;

  environment.systemPackages = with pkgs; [
    smartmontools
    tmux
    pciutils
  ];

  services.smartd = {
    enable = true;
    autodetect = true;
  };
}
