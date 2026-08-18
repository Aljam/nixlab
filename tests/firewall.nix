{ ... }:

let
  testFirewallIsolation = { ... }:
    {
      name = "firewall-isolation";
      nodes = {
        haproxy = { pkgs, ... }: {
          environment.systemPackages = [ pkgs.curl ];
          networking.interfaces.eth1.ipv4.addresses = [{
            address = "192.168.1.1";
            prefixLength = 24;
          }];
        };

        backend = { pkgs, ... }: {
          imports = [ ../modules/features/reverse-proxy-backends.nix ];

          services.grafana.enable = true;
          services.grafana.settings.server.http_port = 3000;

          networking.fleet.proxy.ip = "192.168.1.1";
          networking.interfaces.eth1.ipv4.addresses = [{
            address = "192.168.1.2";
            prefixLength = 24;
          }];
        };

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

        haproxy.succeed("curl --fail --connect-timeout 2 http://192.168.1.2:3000 >/dev/null 2>&1")
        attacker.fail("curl --fail --connect-timeout 2 http://192.168.1.2:3000 >/dev/null 2>&1")
        backend.succeed("curl --fail http://127.0.0.1:3000 >/dev/null 2>&1")
      '';
    };
in
{
  imports = [ testFirewallIsolation ];
}
