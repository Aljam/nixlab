# hosts/r820/configuration.nix
# r820 - Tertiary server
{ config, lib, pkgs, fleet, ... }:
{
  imports = [
    ../../modules/roles/common.nix
    ../../modules/roles/server.nix
    ../../modules/features/monitoring.nix
  ];

  # Set servicesHostIP from fleet for HAProxy backend access
  servicesHostIP = fleet.r820.ip;

  # Host-specific configuration
  networking.hostName = "r820";

  # Timezone
  time.timeZone = "America/New_York";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Console
  console.keyMap = "us";
}
