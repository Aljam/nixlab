# modules/features/postgres.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  sops.secrets."pgadmin_password" = {};
  
  services.postgresql = {
    enable = true;
    settings = {
      listen_addresses = lib.mkForce bindAddr;
      port = 5432;
    };
    
    ensureDatabases = [ "webscraper" "grafana" "aljam" ];
    ensureUsers = [
      { name = "webscraper"; ensureDBOwnership = true; }
      { name = "grafana"; ensureDBOwnership = true; }
      { name = "aljam"; ensureDBOwnership = true; }
    ];
  };

  services.pgadmin = {
    enable = true;
    port = 5050;
    initialEmail = "admin@derezzed.info";
    initialPasswordFile = config.sops.secrets."pgadmin_password".path;
  };

  # Override the service to bind to host IP
  systemd.services.pgadmin = {
    serviceConfig = {
      ExecStart = lib.mkForce [
        ""
        "${pkgs.python3}/bin/python3 -c \"import os; os.environ['SERVER_ADDRESS']='${bindAddr}'; exec(open('${pkgs.pgadmin4}/lib/python3.11/site-packages/pgadmin4/pgAdmin4.py').read())\""
      ];
    };
  };
}
