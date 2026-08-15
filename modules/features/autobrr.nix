{ config, pkgs, domains, fleet, subnets, ... }:
{
  sops.secrets."autobrr_api_key" = {
    owner = "autobrr";
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
