{ config, pkgs, ... }:

{
  # Enable Sanoid for automated snapshotting and pruning
  services.sanoid = {
    enable = true;
    interval = "*:0/15"; # Run snapshot checks every 15 minutes
    
    # Define your retention templates
    templates.storage = {
      hourly = 24;
      daily = 7;
      monthly = 3;
      yearly = 0;
      autosnap = true;
      autoprune = true;
    };

    # Apply templates to your ZFS pools (Adjust pool/dataset names to match yours)
    datasets = {
      "mnt/media" = {
        useTemplate = [ "storage" ];
        recursive = true;
      };
    };
  };

  # Optional: Enable Syncoid for dataset replication (e.g., pushing backups to another host)
  # services.syncoid = {
  #   enable = true;
  #   commonArgs = "--sshkey=/root/.ssh/id_ed25519";
  #   commands."backup-media" = {
  #     source = "tank/media";
  #     target = "root@192.168.1.X:tank/backup-media";
  #     interval = "daily";
  #   };
  # };
}
