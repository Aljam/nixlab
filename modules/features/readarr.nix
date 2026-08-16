# modules/features/readarr.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.readarr = {
    enable = true;
    port = 8787;
  };

  # Set bind address via systemd environment
  systemd.services.readarr = {
    serviceConfig = {
      Environment = "BIND_ADDRESS=${bindAddr}";
    };
  };
}
