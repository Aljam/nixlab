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

  # Create config file that pgadmin4 reads
  # pgadmin4 reads config_local.py from the same directory as config_system.py
  environment.etc."pgadmin/config_local.py".text = ''
    SERVER_ADDRESS = '${bindAddr}'
  '';

  # Make sure the service reloads the config
  systemd.services.pgadmin.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.python3}/bin/python3 -c \"import os; os.environ['SERVER_ADDRESS']='${bindAddr}'; import pgadmin4; pgadmin4.run()\""
  ];
}
