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

  # Override service to set SERVER_ADDRESS env var
  systemd.services.pgadmin.serviceConfig.Environment = [
    "SERVER_ADDRESS=${bindAddr}"
  ];
}
