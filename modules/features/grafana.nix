{ config, pkgs, domains, subnets, ... }:

{
  sops.secrets."grafana-secret-key".owner = "grafana";

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "${subnets.lan}.2";
        http_port = 3000;
        root_url = "https://grafana.${domains.primary}"; 
        domain = "grafana.${domains.primary}";
      };
      security.secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";
        url = "http://${subnets.lan}.2:9090";
        isDefault = true;
      }];
      dashboards.settings.providers = [{
        name = "Default";
        options.path = pkgs.runCommand "grafana-dashboards" {} ''
          mkdir -p $out
          cp ${pkgs.fetchurl {
            url = "https://grafana.com/api/dashboards/1860/revisions/37/download";
            sha256 = "sha256-1DE1aaanRHHeCOMWDGdOS1wBXxOF84UXAjJzT5Ek6mM=";
          }} $out/node-exporter-full.json
        '';
      }];
    };
  };
}
