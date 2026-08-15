{ config, pkgs, domains, fleet, subnets, lib, ... }:

{
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8000;
    };
  };
}
