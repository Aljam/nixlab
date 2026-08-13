{ config, pkgs, lib, domains, ... }:

{   
   imports = [ ../../modules/features/grafana.nix ];
   
   environment.systemPackages = with pkgs; [
    btop
    iotop
    sysstat
  ];
}
