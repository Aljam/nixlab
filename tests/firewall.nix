{ pkgs, ... }:

{
  name = "firewall-isolation";

  nodes = {
    proxy = { ... }: {
      imports = [
        ../modules/features/networking-options.nix
      ];

      networking.firewall.enable = true;
      networking.interfaces.eth1.ipv4.addresses = [
        { address = "192.168.1.1"; prefixLength = 24; }
      ];
      environment.systemPackages = [ pkgs.netcat ];
    };

    backend = { ... }: {
      imports = [
        ../modules/features/networking-options.nix
        ../modules/features/reverse-proxy-backends.nix
      ];

      networking.firewall.enable = true;
      networking.fleet.proxy.ip = "192.168.1.1";
      networking.proxyBackendPorts = [ 3000 ];

      networking.interfaces.eth1.ipv4.addresses = [
        { address = "192.168.1.2"; prefixLength = 24; }
      ];

      services.grafana.enable = true;
      environment.systemPackages = [ pkgs.netcat ];
    };

    attacker = { ... }: {
      imports = [
        ../modules/features/networking-options.nix
      ];

      networking.firewall.enable = true;
      networking.interfaces.eth1.ipv4.addresses = [
        { address = "192.168.1.100"; prefixLength = 24; }
      ];

      environment.systemPackages = [ pkgs.netcat ];
    };
  };

  testScript = ''
    proxy.wait_for_unit("multi-user.target")
    backend.wait_for_unit("multi-user.target")
    attacker.wait_for_unit("multi-user.target")

    proxy.succeed("nc -z -w 2 192.168.1.2 3000")
    attacker.fail("nc -z -w 2 192.168.1.2 3000")
  '';
}
