# nixlab/modules/features/grafana.nix
# Grafana monitoring dashboard with firewall isolation

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.features.grafana;
in
{
  options.modules.features.grafana = {
    enable = lib.mkEnableOption "Grafana monitoring dashboard" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."grafana-secret-key" = {};

    services.grafana = {
      enable = true;
      openFirewall = false;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = 3000;
        };
        security.secret_key = config.sops.secrets."grafana-secret-key".path;
      };
    };
  };
}
