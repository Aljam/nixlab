{ config, pkgs, lib, ... }: {

  # 1. The Headless Browser (Accessible via Web UI)
  virtualisation.oci-containers.containers.firefox = {
    image = "lscr.io/linuxserver/firefox:latest";
    autoStart = true;
    ports = [ "3000:3000" ]; # Access the browser via http://SERVER_IP:3000
    environment = {
      PUID = "1000"; # Match your media user ID
      PGID = "1000"; # Match your media group ID
      TZ = "America/New_York"; # Adjust to your timezone
    };
    volumes = [
      # Map the browser profile to your server's physical storage
      "/var/lib/firefox-container:/config" 
    ];
  };

  # 2. The Extraction Script
  systemd.services.youtube-cookie-sync = {
    description = "Extract YouTube cookies from Firefox container for ytdl-sub";
    requires = [ "docker-firefox.service" ]; # Ensure the container exists
    after = [ "docker-firefox.service" ];
    
    path = [ pkgs.yt-dlp pkgs.coreutils ];
    
    script = ''
      echo "Extracting cookies from Firefox profile..."
      
      # yt-dlp can natively extract cookies from a Firefox profile directory
      # We tell it to pull from the mapped container volume and output a text file
      yt-dlp \
        --cookies-from-browser "firefox:/var/lib/firefox-container/.mozilla/firefox" \
        --cookies /var/lib/ytdl-sub/cookies.txt \
        "https://www.youtube.com" || true
        
      # Ensure ytdl-sub actually has permission to read the new file
      chmod 644 /var/lib/ytdl-sub/cookies.txt
      chown root:media /var/lib/ytdl-sub/cookies.txt
      
      echo "Cookie sync complete."
    '';
    
    serviceConfig = {
      Type = "oneshot";
      User = "root"; # Needs root to read the container volume and write to ytdl-sub
    };
  };

  # 3. The Automation Timer
  systemd.timers.youtube-cookie-sync = {
    description = "Run YouTube cookie extraction nightly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00"; # Run at 3:00 AM every day
      Persistent = true;
    };
  };

  # Ensure the target directory for ytdl-sub exists
  systemd.tmpfiles.rules = [
    "d /var/lib/ytdl-sub 0770 root media - -"
  ];
}
