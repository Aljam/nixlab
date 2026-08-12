{ config, pkgs, ... }:

{
   sops.secrets.grafana-secret-key = {};

   services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        root_url = "https://grafana.${domains.primary}"; 
        domain = "grafana.${domains.primary}";
        serve_from_sub_path = true;
      };
      security = {
        secret_key = config.sops.secrets.grafana-secret-key.path;
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Default";
          options.path = pkgs.fetchurl {
            url = "https://grafana.com/api/dashboards/1860/revisions/37/download";
            sha256 = "sha256-1234567890abcdef1234567890abcdef1234567890a="; # Replace with actual hash after first build failure if needed
          };
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
