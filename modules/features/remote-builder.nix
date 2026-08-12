{ config, pkgs, ... }:

{
  nix = {
    distributedBuilds = true;
    
    # Optional: Don't force builds to the remote if local is faster for tiny packages
    settings.builders-use-substitutes = true;

    buildMachines = [{
      hostName = "192.168.1.4"; # Replace with the R820's actual IP (e.g., "192.168.1.XX") if DNS isn't resolving
      system = "x86_64-linux";
      protocol = "ssh-ng"; # The modern, faster Nix SSH protocol
      
      # The user on the R820 that will execute the build
      sshUser = "aljam"; 
      
      # The SSH key that the local nix-daemon (root) will use to connect
      sshKey = "/root/.ssh/id_ed25519"; 
      
      # The R820 is a massive quad-socket server, let it chew through heavy jobs!
      maxJobs = 32; 
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }];
  };
}
