{ config, pkgs, ... }:

{
  # This enables the Wireshark GUI and, more importantly, configures the 
  # setcap wrappers so your user can capture packets without running as root.
  programs.wireshark.enable = true;

  environment.systemPackages = with pkgs; [
    # Core Network Analysis
    nmap
    tcpdump
    
    # Troubleshooting & Benchmarking
    mtr        # A much better, real-time traceroute
    iperf3     # For testing actual LAN speeds between your servers
    ipcalc     # Handy for calculating subnets

    # Network Visualization & Simulation
    gns3-gui
    gns3-server
    ubridge    # Required by GNS3 to bridge simulated networks to your physical LAN
  ];
}
