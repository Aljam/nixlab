{ config, pkgs, lib, subnets, ... }:

{
  imports = [
    ../features/node-exporter.nix
    ../features/prometheus-alerts.nix
  ];

  networking.defaultGateway.address = "${subnets.lan}.1";
  networking.nameservers = [ "${subnets.lan}.1" ];
  networking.enableIPv6 = false;
  
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 80 443 ];
    # Or if HAProxy is the only service:
    allowedUDPPorts = [];
  };  

  networking.nftables.enable = true;
  networking.networkmanager.enable = false;
  networking.useDHCP = false;
  virtualisation.podman = { enable = true; dockerSocket.enable = true; };
  
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
