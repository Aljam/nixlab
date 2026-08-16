{ config, pkgs, ... }:
{
  services.shoko = {
    enable = true;
    openFirewall = false;
  };
}
