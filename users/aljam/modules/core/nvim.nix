{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    # Search and file finding (Required for Telescope)
    ripgrep
    fd

    # C Compiler (Required for nvim-treesitter to compile syntax highlighting)
    gcc 
    gnumake

    # Utilities
    unzip
    wget
    curl

    # Clipboard support (Wayland and X11)
    wl-clipboard
    xclip
  ];
}
