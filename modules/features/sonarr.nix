# nixlab/modules/features/sonarr.nix
# Sonarr - TV show management

{ config, lib, pkgs, ... }:

{
  options.modules.features.sonarr = {
    enable = lib.mkEnableOption "Sonarr TV show management" // { default = true; };
  };

  config = lib.mkIf config.modules.features.sonarr.enable {
    services.sonarr = {
      enable = true;
    };

    # Firewall: sonarr accessible only from HAProxy (192.168.1.1)
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.1.1 tcp dport 8989 accept
    '';
  };
}
