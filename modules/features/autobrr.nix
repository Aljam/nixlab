{ config, pkgs, domains, fleet, subnets, ... }:
{
  users.groups.autobrr = {};
  users.users.autobrr = {
    isSystemUser = true;
    group = "autobrr";
  };

  sops.secrets."autobrr_api_key" = {
    owner = "autobrr";
    group = "autobrr";
  };

  services.autobrr = {
    enable = true;
    secretFile = config.sops.secrets."autobrr_api_key".path;
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 7777 accept
  '';
}
