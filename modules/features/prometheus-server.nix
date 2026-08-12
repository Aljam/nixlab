{ ... }:

{
  services.prometheus = {
    enable = true;
    port = 9090;
    scrapeConfigs = [
      { 
        job_name = "fleet-nodes"; 
        static_configs = [{ targets = [ "r730xd:9100" "r820:9100" "r730:9100" ]; }]; 
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 9090 ];
}
