{ config, pkgs, ... }:

{
  # Ensure the system has the tools to understand the CIFS filesystem
  environment.systemPackages = [ pkgs.cifs-utils ];

  # --- NAS CIFS Mount ---
  fileSystems."/run/media/aljam/share" = {
    device = "//192.168.2.10/share";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [
      "${automount_opts}"
      "credentials=/etc/nixos/smb-secrets"
      "uid=1000"
      "gid=100"
    ];
  };
}
