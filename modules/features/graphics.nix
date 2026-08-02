{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

    extraPackages = with pkgs; [
      vulkan-validation-layers
    ];
}
