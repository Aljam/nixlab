{ config, pkgs, ... }: 
{
  services.prometheus = {
    enable = true;
    port = 9090;
    
    scrapeConfigs = [
      { 
        job_name = "fleet-nodes"; 
        static_configs = [{ 
          targets = [ 
            "127.0.0.1:9100"        # Scrapes itself (r730xd)
            "192.168.1.3:9100"      # Replace with the actual IP of r730
            "192.168.1.4:9100"      # Replace with the actual IP of r820
          ]; 
        }]; 
      }
    ];
  };

  # Ensure the prometheus port is open on the server hosting it
  networking.firewall.allowedTCPPorts = [ 9090 ];
}
