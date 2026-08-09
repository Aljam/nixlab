{ config, pkgs, lib, ... }:

{
  sops.secrets.restic-password = {};

  # Ensure restic is available fleet-wide on nodes that include this module
  environment.systemPackages = [ pkgs.restic ];

  services.restic.backups = {
    homelab = {
      # Automatically initialize the repository if it doesn't exist yet
      initialize = true;

      # Point this to your storage server (e.g., r730xd ZFS pool via SFTP)
      # Or change to a local directory path if backing up directly on the server
      repository = "sftp:aljam@r730xd:/mnt/backups/${config.networking.hostName}";

      # Securely load the repository password using sops-nix
      passwordFile = config.sops.secrets.restic-password.path;

      # What directories to back up from workstations/servers
      paths = [
        "/home/aljam/nixlab"
        "/home/aljam/Documents"
      ];

      # Ignore build artifacts, caches, and git directories to save space
      exclude = [
        ".git"
        "result"
        "Cache"
        "node_modules"
      ];

      # Run daily at 2:00 AM, catching up if the machine was offline
      timerConfig = {
        OnCalendar = "02:00";
        Persistent = true;
      };

      # Automatic retention policy (Pruning old snapshots)
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
      ];
    };
  };
}
