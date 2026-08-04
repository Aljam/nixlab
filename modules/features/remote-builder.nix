{ config, pkgs, ... }:

{
  nix = {
    distributedBuilds = true;
    buildMachines = [{
      hostName = "r820"; # Make sure this resolves via Tailscale or local DNS
      sshUser = "aljam";
      sshKey = "/root/.ssh/id_ed25519_buildfarm";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 32;       # Unleash those quad-socket threads!
      speedFactor = 3;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
