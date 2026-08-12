{ ... }:

{
  services.prometheus = {
    enable = true;
    port = 9090;
    scrapeConfigs = [
      { 
        job_name = "fleet-nodes"; 
        static_configs = [{ targets = [ "192.168.1.2:9100" "192.168.1.3:9100" "192.168.1.4:9100" ]; }]; 
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 9090 ];
}
