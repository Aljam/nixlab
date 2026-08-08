{ config, pkgs, lib, ... }:

{
  # 1. Install the package
  environment.systemPackages = [ pkgs.ytdl-sub ];

  # 2. Define the execution service
  systemd.services.ytdl-sub = {
    description = "ytdl-sub YouTube automation daemon";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      # Running as your shared media user to prevent permission conflicts with Jellyfin
      User = "media"; 
      Group = "media";
      
      # IMPORTANT: Adjust these paths to where your config and downloads live
      ExecStart = "${pkgs.ytdl-sub}/bin/ytdl-sub sub /var/lib/ytdl-sub/subscriptions.yaml";
      
      # Security & Access
      ProtectSystem = "strict";
      ReadWritePaths = [ 
        "/mnt/pool/media/youtube" # Where your videos download
        "/var/lib/ytdl-sub"       # Where your config/state lives
      ];
    };
  };

  # 3. Define the automation schedule
  systemd.timers.ytdl-sub = {
    description = "Timer for ytdl-sub YouTube automation";
    wantedBy = [ "timers.target" ];
    
    timerConfig = {
      OnCalendar=*-*-*:*:00; # Triggers once a day at midnight. Change to "*-*-* 02:00:00" for 2 AM, etc.
      Persistent = true;    # If the server was off during the trigger, it will run immediately on boot
    };
  };
}
