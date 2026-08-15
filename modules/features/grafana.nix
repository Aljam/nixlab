# nixlab/modules/features/grafana.nix
# Grafana monitoring dashboard with firewall isolation

{ config, lib, pkgs, ... }:

{
  options.modules.features.grafana = {
    enable = lib.mkEnableOption "Grafana monitoring dashboard" // { default = true; };
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
          secret_key_file = config.sops.secrets."grafana-secret-key".path;
          admin_user = "admin";
          admin_password_file = config.sops.secrets."grafana-admin-password".path;
        };
        users = {
          allow_sign_up = false;
          allow_org_create = false;
        };
      };
    };

    # Firewall: grafana accessible only from HAProxy (192.168.1.1)
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.1.1 tcp dport ${toString config.modules.features.grafana.port} accept
    '';
  };
}
