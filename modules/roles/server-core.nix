{ config, pkgs, lib, subnets, ... }:

{
  imports = [
    ../features/monitoring.nix
    ../features/node-exporter.nix
  ];

  networking.defaultGateway.address = "${subnets.lan}.1";
  networking.nameservers = [ "${subnets.lan}.1" ];
  networking.enableIPv6 = false;
  networking.firewall.allowPing = true;
  networking.nftables.enable = true
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
