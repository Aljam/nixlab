{ config, pkgs, domains, fleet, subnets, ... }:
{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vaultwarden.${domains.main}";
      SIGNUPS_ALLOWED = false;
    };
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 8000 accept
  '';
}
