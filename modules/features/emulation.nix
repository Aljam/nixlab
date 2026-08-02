{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- The Emulators (with Debugging capabilities) ---
    mgba       # The absolute best GBA emulator. Includes a powerful memory viewer/debugger crucial for ROM hacking.
    melonDS    # Excellent for Nintendo DS.
    mesen      # The gold standard for NES/SNES/GB/GBC with unparalleled debugging tools.
    retroarchFull # For general testing across multiple cores.

    # --- ROM Hacking & Patching ---
    flips      # The standard for creating and applying IPS and BPS patches.
    asar       # SNES assembler and patcher.

    # --- Reverse Engineering & Hex Editing ---
    imhex      # A world-class reverse engineering hex editor. Incredibly powerful for tearing apart ROM structures.
    wxHexEditor # A great, lightweight alternative for massive files.

    # --- Game Development & Asset Tools ---
    rgbds      # Rednex Game Boy Development System (Assembler/Linker for Game Boy).
    tiled      # A general-purpose tile map editor used heavily in GBA/Pokémon ROM hacking.
  ];
}
