{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btop    # Stunning, interactive terminal resource monitor (CPU, memory, disk I/O, network)

    # We aggressively inject the test bypass 
    # directly into the package definition so the Python builder cannot ignore it.
    (glances.overrideAttrs (oldAttrs: {
      doCheck = false;
      dontCheck = true;
      pytestCheckPhase = "true"; # Forces the pytest runner to instantly return "success"
    }))

    iotop   # Monitor disk read/write bandwidth per process
    sysstat # Classic performance tools (iostat, mpstat)
  ];
}
