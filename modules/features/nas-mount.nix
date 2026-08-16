# modules/features/nas-mount.nix
# NAS mount configuration with sops secrets
{ config, lib, pkgs, ... }:
{
  # File systems
  fileSystems = {
    "/mnt/nas" = {
      device = "//${config.networking.config.networking.fleet.nas.ip}/mnt/user";
      fsType = "cifs";
      options = [
        "credentials=${config.sops.secrets.nas-credentials.path}"
        "uid=1000"
        "gid=1000"
        "iocharset=utf8"
        "noperm"
      ];
    };
  };

  # Sops secrets
  sops.secrets.nas-credentials = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
