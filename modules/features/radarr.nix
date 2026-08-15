# nixlab/modules/features/radarr.nix
# Radarr - Movie management

{ config, lib, pkgs, ... }:

{
  options.modules.features.radarr = {
    enable = lib.mkEnableOption "Radarr movie management" // { default = true; };
  };

  config = lib.mkIf config.modules.features.radarr.enable {
    services.radarr = {
      enable = true;
    };

    # Firewall: radarr accessible only from HAProxy (192.168.1.1)
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.1.1 tcp dport 7878 accept
    '';
  };
}
