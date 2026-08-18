{ config, lib, ... }:

{
  networking.proxyBackendPorts = [ 9093 ];

  services.prometheus.alertmanager = {
    enable = true;

    configuration = {
      global = {
        smtp_from = "alertmanager@example.com";
        smtp_smarthost = "localhost:25";
      };

      route = {
        receiver = "default";
      };

      receivers = [
        {
          name = "default";
        }
      ];
    };
  };
}
