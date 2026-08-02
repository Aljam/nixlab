{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btop
    
    # Workaround for upstream pytest failures
    (glances.overrideAttrs (oldAttrs: {
      doCheck = false;
      dontCheck = true;
      pytestCheckPhase = "true";
    }))

    iotop
    sysstat
  ];
}
