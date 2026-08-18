{ pkgs, lib, ... }:

{
  name = "firewall-isolation";

  nodes = {
    proxy = { ... }:
      {
        networking.firewall.enable = true;
        networking.fleet.proxy.ip = "192.168.1.1";
      };

    backend = { ... }:
      {
        networking.firewall.enable = true;
        networking.fleet.proxy.ip = "192.168.1.1";
        networking.proxyBackendPorts = [ 3000 ];
        imports = [ ../modules/features/reverse-proxy-backends.nix ];
        services.grafana.enable = true;
      };

    attacker = { ... }:
      {
        networking.firewall.enable = true;
      };
  };

  testScript = ''
    proxy.wait_for_unit("multi-user.target")
    backend.wait_for_unit("multi-user.target")
    attacker.wait_for_unit("multi-user.target")

    proxy.succeed("nc -z -w 2 backend 3000")
    attacker.fail("nc -z -w 2 backend 3000")
  '';
}
