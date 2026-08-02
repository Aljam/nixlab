{ config, pkgs, ... }:

{
  services.vaultwarden = {
    enable = true;
    
    # Vaultwarden stores its encrypted database and attachments here.
    # Because you are using ZFS, make sure this path is included in your backup strategies!
    backupDir = "/var/lib/vaultwarden/backup";
    
    config = {
      # The internal port Vaultwarden binds to. 
      # HAProxy will point to this port!
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "127.0.0.1";
      
      # IMPORTANT SECURITY SETTING
      # Leave this as `true` initially so you can create your admin account.
      # Once you create your account via the web UI, change this to `false` and rebuild!
      SIGNUPS_ALLOWED = true; 
      
      # The domain name you plan to use for your password manager 
      # (Update this to match your actual domain)
      DOMAIN = "https://vault.derezzed.info";
    };
  };
}
