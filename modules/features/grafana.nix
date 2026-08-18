{ config, lib, ... }: 

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "grafana.${config.networking.domain}";
        root_url = "https://%(domain)s";
      };
    };
  };

  networking.proxyBackendPorts = [ 3000 ];
}
