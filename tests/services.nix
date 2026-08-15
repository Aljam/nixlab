{ lib, nodes, ... }:

let
  # Test that critical services are running and healthy
  testServiceHealth = { name, nodes, ... }: {
    name = "service-health";
    nodes = {
      server = { config, pkgs, ... }: {
        # Minimal test configuration for services
        services.postgresql = {
          enable = true;
          ensureDatabases = [ "testdb" ];
          ensureUsers = [{
            name = "testuser";
            ensureDBOwnership = true;
          }];
        };
        
        services.grafana = {
          enable = true;
          settings.server.http_port = 3000;
        };
        
        services.vaultwarden = {
          enable = true;
          config.ROCKET_PORT = 8222;
        };
      };
    };
    
    testScript = ''
      server.wait_for_unit("multi-user.target")
      
      # PostgreSQL is running
      server.wait_for_unit("postgresql.service")
      server.succeed("systemctl is-active postgresql")
      
      # PostgreSQL can accept connections
      server.succeed("PGPASSWORD='' psql -U testuser -d testdb -c 'SELECT 1' >/dev/null 2>&1")
      
      # Grafana is running
      server.wait_for_unit("grafana.service")
      server.succeed("curl -f http://localhost:3000/api/health >/dev/null 2>&1")
      
      # Vaultwarden is running
      server.wait_for_unit("vaultwarden.service")
      server.succeed("curl -f http://localhost:8222 >/dev/null 2>&1")
    '';
  };
in
{
  imports = [
    testServiceHealth
  ];
}
