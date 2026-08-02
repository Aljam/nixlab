{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btop    # Stunning, interactive terminal resource monitor (CPU, memory, disk I/O, network)
    glances # Cross-platform curses-based monitoring tool
    iotop   # Monitor disk read/write bandwidth per process
    sysstat # Classic performance tools (iostat, mpstat)
  ];
}
