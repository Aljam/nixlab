{ config, pkgs, lib, domains, ... }:

{
   sops.secrets.grafana-secret-key = {};
   
   environment.systemPackages = with pkgs; [
    btop
    
    # Workaround for upstream pytest failures
    (glances.overrideAttrs (oldAttrs: {
      doCheck = false;
      dontCheck = true;
      pytestCheckPhase = "true";
    }))

    iotop
    sysstat
  ];

 sops.secrets.alertmanager_smtp_password = {};

  # Enable and Configure Alertmanager for Email
  services.prometheus.alertmanager = {
    enable = true;
    port = 9093;
    
    # Securely loads the secret and substitutes $SMTP_PASSWORD below
    environmentFile = config.sops.secrets.alertmanager_smtp_password.path;
    
    configuration = {
      global = {
        # Replace with your SMTP provider (e.g., smtp.gmail.com:587)
        smtp_smarthost = "smtp.mail-provider.com:587"; 
        smtp_from = "alerts@${domains.primary}";
        smtp_auth_username = "your-email@example.com";
        smtp_auth_password = config.sops.secrets.alertmanager_smtp_password.path; 
        smtp_require_tls = true;
      };
      
      route = {
        group_by = [ "alertname" "instance" ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
        receiver = "email";
      };
      
      receivers = [
        {
          name = "email";
          email_configs = [
            {
              # The email address that will receive the alerts
              to = "your-personal-email@example.com";
              send_resolved = true;
              headers = {
                Subject = "[{{ .Status | toUpper }}] {{ .GroupLabels.alertname }} (NixOS Fleet)";
              };
            }
          ];
        }
      ];
    };
  };


  networking.firewall.allowedTCPPorts = [ 9090 3000 9100 9093 ];
}
