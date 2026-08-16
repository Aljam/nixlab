# hosts/r730xd/configuration.nix
# r730xd - Main server
{ config, lib, pkgs, fleet, ... }:
{
  imports = [
    ../../modules/roles/common.nix
    ../../modules/roles/server.nix
    ../../modules/features/monitoring.nix
    ../../modules/features/haproxy.nix
    ../../modules/features/reverse-proxy-backends.nix
  ];

  # Set servicesHostIP from fleet for HAProxy backend access
  servicesHostIP = fleet.r730xd.ip;

  # Host-specific configuration
  networking.hostName = "r730xd";

  # Timezone
  time.timeZone = "America/New_York";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Console
  console.keyMap = "us";
}
