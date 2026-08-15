{ config, pkgs, domains, fleet, subnets, ... }:
{
  sops.secrets."autobrr_api_key" = {
    owner = config.services.autobrr.user;
    group = config.services.autobrr.group;
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
