# modules/features/postgres.nix
# PostgreSQL stays localhost-only.
# pgAdmin binds to servicesHostIP so HAProxy can reach it;
# firewall still restricts the source to the proxy IP only.

{ config, lib, pkgs, ... }:

let
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
  bindIP  = config.servicesHostIP;   # already set by common.nix
in
{
  services.postgresql = {
    enable = true;
    settings = {
      listen_addresses = "localhost";   # never expose Postgres itself
      port = 5432;
    };
  };

  services.pgadmin = {
    enable = true;
    port = 5050;
    openFirewall = false;               # we manage the firewall ourselves

    initialEmail = "admin@derezzed.info";
    initialPasswordFile = config.sops.secrets."pgadmin-password".path;

    settings = {
      # This is the real bind address (the old bindAddress attribute was invalid)
      DEFAULT_SERVER = bindIP;

      # Optional but recommended when behind HAProxy
      # PROXY_X_FOR_COUNT   = 1;
      # PROXY_X_PROTO_COUNT = 1;
    };
  };

  # Only the HAProxy box may talk to pgAdmin.
  # (reverse-proxy-backends.nix already has a broader rule; this is belt-and-suspenders)
  networking.firewall.extraInputRules = lib.mkAfter ''
    ip saddr ${proxyIP} tcp dport 5050 accept comment "HAProxy → pgAdmin"
  '';
}
