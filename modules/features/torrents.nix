{ config, pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    group = "media";
    webuiPort = 8080;
  };

  let
    qbitmanageImage = pkgs.dockerTools.pullImage {
      imageName = "ghcr.io/starbix/qbitmanage";
      imageDigest = "sha256:....";  # registry digest
      sha256 = "sha256-....";       # Nix nar hash from nix-prefetch-docker
      finalImageName = "ghcr.io/starbix/qbitmanage";
      finalImageTag = "v4.11.0";
    };
  in
  {
    virtualisation.oci-containers.containers.qbitmanage = {
      image = "ghcr.io/starbix/qbitmanage:v4.11.0";
      imageFile = qbitmanageImage;
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
  };
}
