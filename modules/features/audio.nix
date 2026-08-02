{ config, pkgs, ... }:

{
  # RealtimeKit is essential for low-latency audio scheduling
  security.rtkit.enable = true;

  # --- Low-Latency Audio Stack ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # Critical for 32-bit audio in Fightcade/Wine
    pulse.enable = true;
    
    # Enable JACK for ultra-low latency rhythm gaming (Sound Voltex)
    jack.enable = true; 
  };

  # Optional: Helpful GUI tools for managing your audio and inputs
  environment.systemPackages = with pkgs; [
    qjackctl # GUI to map audio connections (great for JACK)
    pavucontrol # Standard volume mixer
  ];
}
