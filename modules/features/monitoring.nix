{ config, pkgs, lib, ... }:

{     
   environment.systemPackages = with pkgs; [
    btop
    iotop
    sysstat
  ];
}
