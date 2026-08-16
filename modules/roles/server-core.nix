# modules/roles/server-core.nix
# Core server configuration: networking, monitoring, and essential services
# Applied to: r730, r730xd, and other servers
{
  config,
  lib,
  pkgs,
  ...  # fleet, subnets, domains wired via common.nix
}:

let
  # Use proxy IP from fleet config as gateway
  gateway = config.networking.fleet.proxy.ip or "192.168.1.1";
in
{
  # Disable NetworkManager on servers (use systemd-networkd)
  networking.networkmanager.enable = false;

  # Disable IPv6
  networking.useIPv6 = false;

  # Use nftables for firewall
  networking.nftables.enable = true;

  # Gateway and DNS from fleet configuration
  networking.defaultGateway = gateway;
  networking.nameservers = [ gateway "1.1.1.1" "8.8.8.8" ];

  # Firewall: Allow HTTP/HTTPS for reverse proxy
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Container runtime
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  # Monitoring stack
  imports = [
    ../features/node-exporter.nix
    ../features/prometheus-alerts.nix
    ../features/reverse-proxy-backends.nix
  ];

  # Hardware monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # System packages for servers
  environment.systemPackages = [
    pkgs.htop
    pkgs.btop
    pkgs.lsof
    pkgs.tcpdump
    pkgs.wireguard-tools
    pkgs.mkcert
  ];
}
