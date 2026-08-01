{ config, lib, pkgs, ... }:

{
  # Ensure required utilities are available in the system environment
  environment.systemPackages = with pkgs; [
    lm_sensors
    ipmitool
    gawk
    coreutils
  ];

  # Systemd service to dynamically adjust Dell PowerEdge fan speeds based on CPU temperature
  systemd.services.dell-fans = {
    description = "Dell PowerEdge Dynamic CPU Fan Control";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";
      ExecStart = pkgs.writeShellScript "dell-fans-loop" ''
        PATH=$PATH:${lib.makeBinPath [ pkgs.ipmitool pkgs.lm_sensors pkgs.gawk pkgs.coreutils ]}

        # Switch Dell iDRAC out of automatic control into manual fan mode
        ipmitool raw 0x30 0x30 0x01 0x0 > /dev/null 2>&1

        while true; do
          # Extract the highest temperature reading across all CPU cores
          CPU_TEMP=$(sensors | grep -E "Core [0-9]+" | awk '{print $3}' | tr -d '+' | cut -d'.' -f1 | sort -nr | head -n1)

          # Failsafe default if sensors returns an empty or invalid value
          if ! [[ "$CPU_TEMP" =~ ^[0-9]+$ ]]; then
            CPU_TEMP=40
          fi

          # Safe fan curve based on CPU temperature
          if [ "$CPU_TEMP" -lt 40 ]; then
            FAN_HEX="0x14"
          elif [ "$CPU_TEMP" -ge 40 ] && [ "$CPU_TEMP" -lt 55 ]; then
            FAN_HEX="0x1E"
          elif [ "$CPU_TEMP" -ge 55 ] && [ "$CPU_TEMP" -lt 70 ]; then
            FAN_HEX="0x32"
          else
            FAN_HEX="0x5A"
          fi

          # Send raw IPMI command to set fan speed percentage
          ipmitool raw 0x30 0x30 0x02 0xff $FAN_HEX > /dev/null 2>&1

          sleep 10
        done
      '';
      ExecStop = pkgs.writeShellScript "dell-fans-stop" ''
        # Return fans safely back to native Dell BIOS automatic control when stopped
        ${pkgs.ipmitool}/bin/ipmitool raw 0x30 0x30 0x01 0x01 > /dev/null 2>&1
      '';
    };
  };
}
