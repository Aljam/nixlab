{ config, pkgs, subnets, ... }:

{
  services.qbittorrent = {
    enable = true;
    group = "media";
    webuiPort = 8080;

    # Fixed peer port (pick any high port you like; forward this on the router if you want incoming peers)
    torrentingPort = 6881;

    # Do NOT use openFirewall — it would also open the WebUI
    openFirewall = false;

    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          # WebUI only on localhost; HAProxy / local access only
          Address = "${subnets.lan}.2";
          Port = 8080;
          # Optional: skip auth for pure localhost (keep auth if you prefer)
          # LocalHostAuth = false;
        };
      };
      BitTorrent = {
        # Optional hardening / consistency
        # Session\Port = 6881;  # module already passes --torrenting-port
      };
    };
  };

  # Only BT listening port — TCP (peers) + UDP (DHT / µTP)
  networking.firewall.allowedTCPPorts = [ 6881 ];
  networking.firewall.allowedUDPPorts = [ 6881 ];

  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.qbitmanage = {
    image = "ghcr.io/starbix/qbitmanage:v4.11.0";
    environment = {
      QBT_RUN = "true";
      QBT_SCHEDULE = "1440";
    };
    volumes = [
      "/var/lib/qbitmanage:/config"
      "/mnt/media:/data/media"
      "/var/lib/qbittorrent:/qbittorrent"
    ];
  };
}
