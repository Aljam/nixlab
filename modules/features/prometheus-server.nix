# modules/features/prometheus-server.nix
# DRY: Use shared proxy IP from flake.nix instead of hardcoding 192.168.1.1
{ config, lib, pkgs, ... }:

let
  # Use the fleet's reverse proxy IP from flake.nix
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
in
{
  services.prometheus = {
    enable = true;
    port = 9090;
    # Bind to localhost - reverse proxy provides external access
    listenAddress = "127.0.0.1";
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{ targets = ["localhost:9090"]; }];
      }
      {
        job_name = "node";
        static_configs = [{ targets = ["localhost:9100"]; }];
      }
    ];
  };

  # Firewall: Allow only from reverse proxy (not hardcoded IP)
  networking.firewall.extraInputRules = ''
    # Prometheus: Only allow from reverse proxy
    ip saddr ${proxyIP} tcp dport 9090 accept
  '';
}
