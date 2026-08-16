# modules/features/readarr.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.readarr = {
    enable = true;
  };

  # Inject BindAddress into config.xml on start
  systemd.services.readarr = {
    serviceConfig = {
      ExecStartPre = [
        "${pkgs.gnused}/bin/sed -i 's|</Config>|  <BindAddress>${bindAddr}</BindAddress>\\n</Config>|' /var/lib/readarr/config.xml || true"
      ];
    };
  };
}
