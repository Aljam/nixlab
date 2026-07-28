{ config, lib, pkgs, ... }:

let
  # The bash script that loops, reads the GPU temp, and sets the fan speed via IPMI
  fanScript = pkgs.writeShellScriptBin "dell-fan-control" ''
    # Disable Dell's automatic fan control (Enable manual mode)
    ${pkgs.ipmitool}/bin/ipmitool raw 0x30 0x30 0x01 0x00

    while true; do
      # Fetch the highest GPU temperature using nvidia-smi
      GPU_TEMP=$(${pkgs.linuxPackages.nvidia_x11}/bin/nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | sort -nr | head -n1)

      # Failsafe if nvidia-smi fails to return a value
      if [ -z "$GPU_TEMP" ]; then
        GPU_TEMP=50 
      fi

      # The Thermal Curve (Temperatures to Fan PWM Hex Values)
      if [ "$GPU_TEMP" -gt 80 ]; then
        HEX_SPEED="0x64" # 100%
      elif [ "$GPU_TEMP" -gt 70 ]; then
        HEX_SPEED="0x46" # 70%
      elif [ "$GPU_TEMP" -gt 60 ]; then
        HEX_SPEED="0x32" # 50%
      elif [ "$GPU_TEMP" -gt 50 ]; then
        HEX_SPEED="0x23" # 35%
      else
        HEX_SPEED="0x14" # 20%
      fi

      # Push the speed to the Dell motherboard
      ${pkgs.ipmitool}/bin/ipmitool raw 0x30 0x30 0x02 0xff $HEX_SPEED
      
      # Wait 10 seconds before polling again
      sleep 10
    done
  '';
in
{
  options.hardware.dell-fan-control.enable = lib.mkEnableOption "Dell IPMI GPU Fan Control";

  config = lib.mkIf config.hardware.dell-fan-control.enable {
    # Ensure ipmitool is installed on the system
    environment.systemPackages = [ pkgs.ipmitool ];

    # The background daemon that runs your fan script
    systemd.services.dell-fan-control = {
      description = "Dell PowerEdge Fan Control (NVIDIA GPU Target)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${fanScript}/bin/dell-fan-control";
        Restart = "always";
        RestartSec = "10";
        User = "root"; # IPMI commands require root privileges
      };
    };

    # CRITICAL FAILSAFE: Restore Dell's automatic fan control if the server shuts down or the service crashes
    systemd.services.dell-fan-failsafe = {
      description = "Restore Dell Auto Fan Control on Shutdown";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "${pkgs.ipmitool}/bin/ipmitool raw 0x30 0x30 0x01 0x01";
      };
    };
  };
}
