{ config, pkgs, lib, ... }:

let
  hostname = config.networking.hostName;
  bindAddr = config.networking.fleet.${hostname}.ip;
in
{
  sops.secrets.pgadmin_password = {
    owner = "pgadmin";
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    settings.password_encryption = "scram-sha-256";
    authentication = lib.mkOverride 10 ''
      local all all peer
      host all all 127.0.0.1/32 scram-sha-256
      host all all ${config.networking.subnets.lan}.0/24 scram-sha-256
    '';
    ensureDatabases = [ "webscraper" "admin" ];
    ensureUsers = [
      {
        name = "webscraper";
        ensureDBOwnership = true;
      }
      {
        name = "admin";
        ensureDBOwnership = true;
      }
    ];
  };

  services.pgadmin = {
    enable = true;
    initialEmail = "admin@derezzed.info";
    initialPasswordFile = config.sops.secrets.pgadmin_password.path;
    port = 5050;
  };

  # Override pgadmin service to bind to network interface
  systemd.services.pgadmin = {
    serviceConfig = {
      ExecStart = lib.mkForce [
        ""
        "${pkgs.python3}/bin/python3 -c \"import os; os.environ['SERVER_ADDRESS']='${bindAddr}'; exec(open('${pkgs.pgadmin4}/lib/python3.11/site-packages/pgadmin4/pgAdmin4.py').read())\""
      ];
      Environment = [
        "SERVER_ADDRESS=${bindAddr}"
        "PYTHONPATH=${pkgs.pgadmin4}/lib/python3.11/site-packages"
      ];
    };
  };

  # Allow direct access to pgadmin
  networking.firewall.interfaces.eno1.allowedTCPPorts = [ 5432 5050 ];
  networking.firewall.extraInputRules = ''
    ip saddr ${config.networking.fleet.proxy.ip} tcp dport 5050 accept
  '';
}
