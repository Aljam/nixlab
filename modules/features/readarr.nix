# modules/features/readarr.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.readarr = {
    enable = true;
  };

  # Override the service to write config before start
  systemd.services.readarr = {
    serviceConfig = {
      ExecStartPre = [
        "${pkgs.writeShellScript "readarr-fix-config" ''
          CONFIG="/var/lib/readarr/config.xml"
          if [ -f "$CONFIG" ] && ! grep -q "<BindAddress>" "$CONFIG"; then
            ${pkgs.gnused}/bin/sed -i "/<InstanceName>/a\\  <BindAddress>${bindAddr}</BindAddress>" "$CONFIG"
          fi
        ''}"
      ];
    };
  };
}
