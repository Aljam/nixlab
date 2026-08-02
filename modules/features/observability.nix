{ config, pkgs, ... }:

{
  services.prometheus = {
    enable = true;
    port = 9090;
    scrapeConfigs = [
      {
        job_name = "nixos-local";
        static_configs = [
          { targets = [ "127.0.0.1:9100" ]; }
        ];
      }
      # If you want to scrape other servers in your fleet, add their IPs here:
      # {
      #   job_name = "r730-compute";
      #   static_configs = [ { targets = [ "192.168.1.X:9100" ]; } ];
      # }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        root_url = "https://grafana.derezzed.info"; 
        domain = "https://grafana.derezzed.info";
        serve_from_sub_path = true;
      };
      security = {
        secret_key = "$__file{${pkgs.writeText "grafana-secret-key" "SW2YcwTIb9zpOOhoPsMm"}}";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:9090"; # Points to your local Prometheus database
          isDefault = true;
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 9090 3000 ];
}
