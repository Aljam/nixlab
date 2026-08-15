# nixlab/modules/features/grafana.nix
# Grafana monitoring dashboard with firewall isolation

{ config, lib, pkgs, ... }:

{
  options.modules.features.grafana = {
    enable = lib.mkEnableOption "Grafana monitoring dashboard";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Grafana port";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "grafana.${config.networking.hostName}.local";
      description = "Grafana domain";
    };
  };

  config = lib.mkIf config.modules.features.grafana.enable {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = config.modules.features.grafana.port;
          domain = config.modules.features.grafana.domain;
          root_url = "https://${config.modules.features.grafana.domain}";
        };
        security = {
          admin_user = "admin";
          admin_password_file = "/var/lib/sops/secrets.yaml";
        };
        users = {
          allow_sign_up = false;
          allow_org_create = false;
        };
      };
    };

    # Firewall: Grafana accessible only from HAProxy
    networking.firewall.allowedTCPPorts = [ config.modules.features.grafana.port ];
  };
}
