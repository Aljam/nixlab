{ config, pkgs, subnets, ... }: 
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
            "${subnets.lan}.3:9100"
            "${subnets.lan}.4:9100"
          ]; 
        }]; 
      }
    ];
  };

  # Ensure the prometheus port is open on the server hosting it
  networking.firewall.allowedTCPPorts = [ 9090 9100 ];
}
