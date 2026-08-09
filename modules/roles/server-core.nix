{ config, pkgs, lib, subnets, ... }:

{
  imports = [
    ../features/monitoring.nix
  ];

  networking.defaultGateway = "${subnets.lan}.1";
  networking.nameservers = [ "${subnets.lan}.1" ];

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

  networking.firewall.allowedTCPPorts = [
    22    # SSH
    80    # HTTP
    443   # HTTPS
  ];
}
