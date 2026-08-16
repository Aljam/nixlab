# modules/features/nas-mount.nix
# Security: Use sops-managed credentials and avoid hardcoding
{ config, lib, pkgs, ... }:

let
  # Make NAS server configurable per-host or use a default
  nasServer = config.services.nas.server or "192.168.2.10";
  nasShare = config.services.nas.share or "share";
  # Credentials managed by sops
  credsFile = config.sops.secrets."nas-credentials".path;
in
{
  # Define options for NAS configuration
  options.services.nas = {
    server = lib.mkOption {
      type = lib.types.str;
      default = "192.168.2.10";
      description = "NAS server IP address";
    };
    share = lib.mkOption {
      type = lib.types.str;
      default = "share";
      description = "NAS share name";
    };
  };

  # Mount configuration
  fileSystems."/mnt/nas" = {
    device = "//${nasServer}/${nasShare}";
    fsType = "cifs";
    options = [
      "credentials=${credsFile}"
      "uid=1000"
      "gid=1000"
      "rw"
      "x-systemd.automount"
      "x-systemd.mount-timeout=30"
      "nofail"
    ];
  };

  # Ensure credentials file is managed by sops
  # Add to .sops.yaml:
  # - path: secrets/nas-credentials.yaml.enc
  #   key: nas-credentials
  #   owner: root
  #   group: root
  #   mode: "0600"
  sops.secrets."nas-credentials" = {
    owner = "root";
    group = "root";
    mode = "0600";
    # Format: username=xxx\npassword=xxx
  };
}
