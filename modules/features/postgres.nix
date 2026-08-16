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

  # Use the NixOS module for setup but override the service completely
  services.pgadmin = {
    enable = true;
    port = 5050;
    initialEmail = "admin@derezzed.info";
    initialPasswordFile = config.sops.secrets."pgadmin_password".path;
  };

  # Create a wrapper script that sets SERVER_ADDRESS properly
  environment.etc."pgadmin/config_local.py".text = ''
    SERVER_ADDRESS = '${bindAddr}'
  '';

  # The pgadmin4 module uses a wrapper that imports pgadmin4 and runs it
  # We need to patch the ExecStart to set SERVER_ADDRESS before import
  systemd.services.pgadmin.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.python3}/bin/python3 -c \"import os; os.environ['SERVER_ADDRESS']='${bindAddr}'; from pgadmin4 import pgAdmin4; pgAdmin4.run()\""
  ];
  
  # Set PYTHONPATH to include pgadmin4
  systemd.services.pgadmin.serviceConfig.Environment = [
    "PYTHONPATH=${pkgs.pgadmin4}/lib/python3.11/site-packages"
  ];
}
