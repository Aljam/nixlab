{ config, pkgs, ... }:

{
  imports = [
    ../features/sanoid.nix
    # You can also add other storage/ZFS management features here later
  ];
}
