{ config, pkgs, domains, fleet, subnets ... }:

let
  # HAProxy runs on pfSense gateway
  proxy = "${subnets.lan}.1";
in
{
  # SOPS secrets for Grafana
  sops.secrets = {
    "grafana-secret-key".owner = "grafana";
    "grafana-admin-password".owner = "grafana";
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        # Bind to specific IP (HAProxy needs to reach it)
        http_addr = "${fleet.r730xd.ip}";
        http_port = 3000;
        root_url = "https://grafana.${domains.primary}";
        domain = "grafana.${domains.primary}";
      };
      security = {
        # Secret key from SOPS
        secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
        # Admin credentials from SOPS
        admin_user = "admin";
        admin_password = "$__file{${config.sops.secrets."grafana-admin-password".path}}";
        # Disable anonymous access
        allow_embedding = false;
        # Cookie security
        cookie_secure = true;
        cookie_samesite = "lax";
      };
      # Disable anonymous authentication
      auth.anonymous = {
        enabled = false;
      };
      # User management
      users = {
        # Disable public signups
        allow_sign_up = false;
        allow_org_create = false;
        # Auto-assign new users to Viewer role
        auto_assign_org_role = "Viewer";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";
        url = "http://${fleet.r730xd.ip}:9090";
        isDefault = true;
        # Add authentication if Prometheus has auth
        # basicAuth = true;
        # basicAuthUser = "prometheus";
        # secureJsonData.basicAuthPassword = "$__env{PROMETHEUS_PASSWORD}";
      }];
      dashboards.settings.providers = [{
        name = "Default";
        options.path = pkgs.runCommand "grafana-dashboards" {} ''
          mkdir -p $out
          cp ${pkgs.fetchurl {
            url = "https://grafana.com/api/dashboards/1860/revisions/37/download";
            sha256 = "sha256-1DE1aaanRHHeCOMWDGdOS1wBXxOF84UXAjJzT5Ek6mM=";
          }} $out/node-exporter-full.json
          # Add more dashboards as needed
        '';
      }];
    };
  };

  # Firewall: Only allow HAProxy (pfSense) and localhost to access Grafana
  networking.firewall.extraInputRules = ''
    ip saddr ${proxy} tcp dport 3000 accept
    ip saddr 127.0.0.1 tcp dport 3000 accept
  '';
}
