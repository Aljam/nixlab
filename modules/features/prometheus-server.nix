# nixlab/modules/features/prometheus-server.nix
# Prometheus monitoring server

{ config, lib, pkgs, ... }:

{
  options.modules.features.prometheus-server = {
    enable = lib.mkEnableOption "Prometheus monitoring server";
  };

  config = lib.mkIf config.modules.features.prometheus-server.enable {
    services.prometheus = {
      enable = true;
    };

    # Firewall: prometheus accessible only from HAProxy (192.168.1.1)
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.1.1 tcp dport 9090 accept
    '';
  };
}
