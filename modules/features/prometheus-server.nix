{ config, pkgs, fleet, ... }: 
{
  services.prometheus = {
    enable = true;
    port = 9090;
    
    scrapeConfigs = [
      { 
        job_name = "fleet-nodes"; 
        static_configs = [{ 
          targets = [ 
            "127.0.0.1:9100"
            "${fleet.r730.ip}:9100"
            "${fleet.r820.ip}:9100"
          ]; 
        }]; 
      }
    ];
  };
}
