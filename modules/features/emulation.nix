{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- The Emulators (with Debugging capabilities) ---
    mgba       # The absolute best GBA emulator. Includes a powerful memory viewer/debugger crucial for ROM hacking.
    melonDS    # Excellent for Nintendo DS.
    mesen      # The gold standard for NES/SNES/GB/GBC with unparalleled debugging tools.
    retroarch-full # For general testing across multiple cores.

    # --- ROM Hacking & Patching ---
    flips      # The standard for creating and applying IPS and BPS patches.
    asar       # SNES assembler and patcher.

    # --- Reverse Engineering & Hex Editing ---
    imhex      # A world-class reverse engineering hex editor. Incredibly powerful for tearing apart ROM structures.
    # wxHexEditor # A great, lightweight alternative for massive files.

    # --- Game Development & Asset Tools ---
    rgbds      # Rednex Game Boy Development System (Assembler/Linker for Game Boy).
    tiled      # A general-purpose tile map editor used heavily in GBA/Pokémon ROM hacking.

    # --- 3D Console Emulators ---
    
    # PlayStation Family
    duckstation # PS1: The undisputed king of modern PS1 emulation (upscaling, PGXP anti-jitter).
    pcsx2       # PS2: The gold standard. Runs perfectly on Wayland/X11.
    rpcs3       # PS3: Incredibly CPU heavy, but your 5950X will completely destroy it.
    ppsspp      # PSP: Flawless upscaling and performance.

    # Nintendo Family
    dolphin-emu # GameCube / Wii: The legendary emulator. 
    cemu        # Wii U: Now fully native to Linux, amazing for Breath of the Wild/Mario Kart 8.

    emulationstation-de  # The best UI for massive ROM libraries
  ];

  services.udev.packages = [ pkgs.dolphin-emu ]; # Grants Dolphin raw access to GC controller adapters
}
