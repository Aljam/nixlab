# nixlab/modules/features/node-exporter.nix
# Prometheus Node Exporter

{ config, lib, pkgs, ... }:

{
  options.modules.features.node-exporter = {
    enable = lib.mkEnableOption "Prometheus Node Exporter";
  };

  config = lib.mkIf config.modules.features.node-exporter.enable {
    services.prometheus.exporters.node = {
      enable = true;
    };

    # Firewall: node-exporter accessible only from HAProxy (192.168.1.1)
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.1.1 tcp dport 9100 accept
    '';
  };
}
