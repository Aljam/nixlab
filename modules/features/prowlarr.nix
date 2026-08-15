# nixlab/modules/features/prowlarr.nix
# Prowlarr - Indexer management for arr applications

{ config, lib, pkgs, ... }:

{
  options.modules.features.prowlarr = {
    enable = lib.mkEnableOption "Prowlarr indexer management";
  };

  config = lib.mkIf config.modules.features.prowlarr.enable {
    services.prowlarr = {
      enable = true;
    };

    # Firewall: prowlarr accessible only from HAProxy (192.168.1.1)
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.1.1 tcp dport 9696 accept
    '';
  };
}
