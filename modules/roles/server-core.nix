{ config, pkgs, lib, ... }:

{
  imports = [
    ../features/sanoid.nix
    ../features/monitoring.nix
  ];

  environment.systemPackages = with pkgs; [
    smartmontools
    tmux
    htop
    lm_sensors
    pciutils
  ];

  services.smartd = {
    enable = true;
    autodetect = true;
  };

  services.zfs.autoScrub.enable = lib.mkDefault true;
  services.zfs.autoScrub.interval = lib.mkDefault "weekly";
}
