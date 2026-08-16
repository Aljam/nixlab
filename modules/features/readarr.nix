# modules/features/readarr.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.readarr = {
    enable = true;
  };

  # Manually set config via systemd ExecStartPre
  systemd.services.readarr = {
    serviceConfig = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/sed -i 's|<InstanceName>Readarr</InstanceName>|<InstanceName>Readarr</InstanceName>\\n  <BindAddress>${bindAddr}</BindAddress>|' /var/lib/readarr/config.xml || true"
      ];
    };
  };
}
