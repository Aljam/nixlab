{ config, lib, pkgs, ... }:

let
  # The bash script that loops, reads the CPU/GPU temps, and sets the fan speed via IPMI
  fanScript = pkgs.writeShellScriptBin "dell-fan-control" ''
    # Disable Dell's automatic fan control (Enable manual mode)
    ${pkgs.ipmitool}/bin/ipmitool raw 0x30 0x30 0x01 0x00

    while true; do
      # 1. Fetch the highest GPU temperature
      GPU_TEMP=$(${pkgs.linuxPackages.nvidia_x11}/bin/nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | sort -nr | head -n1)
      if [ -z "$GPU_TEMP" ]; then 
        GPU_TEMP=40 
      fi

      # 2. Fetch the highest CPU core temperature using lm_sensors
      # This pulls the raw sensor data, isolates the temp inputs, strips decimals, and grabs the highest number.
      CPU_TEMP=$(${pkgs.lm_sensors}/bin/sensors -u | grep -i 'temp[0-9]_input' | awk '{print $2}' | cut -d. -f1 | sort -nr | head -n1)
      if [ -z "$CPU_TEMP" ]; then 
        CPU_TEMP=40 
      fi

      # 3. Determine the hottest component
      if [ "$GPU_TEMP" -gt "$CPU_TEMP" ]; then
        MAX_TEMP=$GPU_TEMP
      else
        MAX_TEMP=$CPU_TEMP
      fi

      # 4. The Unified Thermal Curve (Temperatures to Fan PWM Hex Values)
      if [ "$MAX_TEMP" -gt 80 ]; then
        HEX_SPEED="0x64" # 100%
      elif [ "$MAX_TEMP" -gt 70 ]; then
        HEX_SPEED="0x46" # 70%
      elif [ "$MAX_TEMP" -gt 60 ]; then
        HEX_SPEED="0x32" # 50%
      elif [ "$MAX_TEMP" -gt 50 ]; then
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
  options.hardware.dell-fan-control.enable = lib.mkEnableOption "Dell IPMI Unified Fan Control";

  config = lib.mkIf config.hardware.dell-fan-control.enable {
    # Ensure ipmitool and lm_sensors are installed for the daemon
    environment.systemPackages = with pkgs; [ 
      ipmitool 
      lm_sensors 
    ];

    # The background daemon that runs your fan script
    systemd.services.dell-fan-control = {
      description = "Dell PowerEdge Fan Control (CPU/GPU Target)";
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
