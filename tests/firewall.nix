{ lib, nodes, ... }:

let
  # Test that firewall blocks direct access but allows HAProxy
  testFirewallIsolation = { name, nodes, ... }: {
    name = "firewall-isolation";
    nodes = {
      # Simulated HAProxy server (pfSense)
      haproxy = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.curl ];
      };
      
      # Backend server with services
      backend = { config, pkgs, ... }: {
        # Minimal test configuration
        services.grafana.enable = true;
        services.grafana.settings.server.http_port = 3000;
        
        # Simulate HAProxy IP on eth1
        networking.interfaces.eth1.ipv4.addresses = [{
          address = "192.168.1.1";
          prefixLength = 24;
        }];
        
        # Firewall rules (only allow HAProxy IP)
        networking.firewall.extraInputRules = ''
          ip saddr 192.168.1.1 tcp dport 3000 accept
        '';
      };
      
      # Attacker on LAN
      attacker = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.curl ];
        networking.interfaces.eth1.ipv4.addresses = [{
          address = "192.168.1.100";
          prefixLength = 24;
        }];
      };
    };
    
    testScript = ''
      backend.wait_for_unit("multi-user.target")
      haproxy.wait_for_unit("multi-user.target")
      attacker.wait_for_unit("multi-user.target")
      
      # HAProxy can reach Grafana (port 3000)
      haproxy.succeed("curl -f http://backend:3000 >/dev/null 2>&1")
      
      # Attacker cannot reach Grafana directly (firewall blocks it)
      attacker.fail("curl -f http://backend:3000 --connect-timeout 2")
      
      # Localhost can reach Grafana
      backend.succeed("curl -f http://localhost:3000 >/dev/null 2>&1")
    '';
  };
in
{
  imports = [
    testFirewallIsolation
  ];
}
