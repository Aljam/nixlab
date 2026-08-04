{ config, pkgs, ... }:

{
  programs.fish.enable = true;

  nixpkgs.config.allowUnfree = true;

  users.users.aljam = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHzrMiro1XD8krk5Kb4EWQ+rGjmgKXha/OuOmUZcopRL navi-desktop"
    ];
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "wireshark" "ubridge" "video" "render" "media" "input" "plugdev" ];
    shell = pkgs.fish; # Or whichever shell you use
  };
}
