{ config, pkgs, ... }:

{

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  ### GUI (KDE Plasma)
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  ### Desktop Programs & Gaming
  programs = {
    kdeconnect.enable = true;
    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      protontricks.enable = true;
    };
  };

  # Enable Pipewire for modern audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Standard Desktop Apps
  environment.systemPackages = with pkgs; [
    firefox
    git
    kitty
  ];
}

}
