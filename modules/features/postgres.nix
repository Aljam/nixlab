{ config, lib, pkgs, ... }:

let
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
  # Prefer the host-specific IP if you set servicesHostIP, otherwise fall back
  bindIP  = config.servicesHostIP or "0.0.0.0";
in
{
  sops.secrets."pgadmin_password" = {};
  
  services.postgresql = {
    enable = true;
    settings = {
      listen_addresses = "localhost";   # keep Postgres local
      port = 5432;
    };
  };

  services.pgadmin = {
    enable = true;
    port = 5050;
    openFirewall = true;               # do NOT open to the world
    initialEmail = "admin@derezzed.info";
    initialPasswordFile = config.sops.secrets."pgadmin_password".path;

    settings = {
      DEFAULT_SERVER = bindIP;          # ← this is the real bind address
      # optional but useful behind a reverse proxy
      # PROXY_X_FOR_COUNT = 1;
      # PROXY_X_PROTO_COUNT = 1;
    };
  };

  # Firewall: only the HAProxy box may reach pgAdmin
  networking.firewall.extraInputRules = ''
    ip saddr ${proxyIP} tcp dport 5050 accept comment "HAProxy → pgAdmin"
  '';
}
