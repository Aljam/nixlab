# hosts/r730/configuration.nix
# r730 - Server
{ config, lib, pkgs, fleet, ... }:
{
  imports = [
    ../../modules/roles/common.nix
    ../../modules/roles/server.nix
    ../../modules/features/monitoring.nix
  ];

  # Set servicesHostIP from fleet for HAProxy backend access
  servicesHostIP = fleet.r730.ip;

  # Host-specific configuration
  networking.hostName = "r730";

  # Timezone
  time.timeZone = "America/New_York";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Console
  console.keyMap = "us";
}
