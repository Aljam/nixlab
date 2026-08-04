{ config, pkgs, lib, subnets, ... }:

{
  imports = [
    ../features/sanoid.nix
    ../features/monitoring.nix
  ];

  networking.defaultGateway = "${subnets.lan}.1";
  networking.nameservers = [ "${subnets.lan}.1" ];

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
}
