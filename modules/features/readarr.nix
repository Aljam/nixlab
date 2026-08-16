# modules/features/readarr.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.readarr = {
    enable = true;
  };

  # Override systemd service to set bind address and port
  systemd.services.readarr = {
    serviceConfig = {
      Environment = [
        "BIND_ADDRESS=${bindAddr}"
        "PORT=8787"
      ];
    };
  };
}
