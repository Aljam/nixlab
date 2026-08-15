# nixlab/modules/features/grafana.nix
# Grafana monitoring dashboard with firewall isolation

{ config, lib, pkgs, ... }:

{
  options.modules.features.grafana = {
    enable = lib.mkEnableOption "Grafana monitoring dashboard";
  };

  config = lib.mkIf config.modules.features.grafana {
    services.grafana = {
      enable = true;
      openFirewall = false;
      settings.server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
    };
  };
}
