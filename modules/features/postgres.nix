# modules/features/postgres.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
  pgadminPkg = pkgs.pgadmin4;
  python3 = pkgs.python3;
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

  # Disable built-in pgadmin and use custom service
  services.pgadmin.enable = false;
  
  systemd.services.pgadmin = {
    description = "pgAdmin4";
    after = [ "network.target" "postgresql.service" ];
    wants = [ "network.target" "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "postgres";
      Group = "postgres";
      WorkingDirectory = "/var/lib/pgadmin";
      Environment = "SERVER_ADDRESS=${bindAddr}";
      ExecStart = "${python3}/bin/python3 ${pgadminPkg}/lib/python3.11/site-packages/pgadmin4/pgAdmin4.py";
      Restart = "always";
    };
    
    preStart = ''
      mkdir -p /var/lib/pgadmin
      chown postgres:postgres /var/lib/pgadmin
    '';
  };
}
EOF

git add modules/features/postgres.nix
git commit -m "fix(postgres.nix): custom pgadmin service with SERVER_ADDRESS"
git push

Then rebuild:

bash
nixos-rebuild switch --flake .#r820
systemctl restart pgadmin.service
journalctl -u pgadmin.service -n 20 --no-pager
sleep 5
ss -tlnp | grep 5050

Artifacts
16
Sources
119
