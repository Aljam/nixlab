{ config, pkgs, ... }:

{
  services.displayManager.sddm.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-validation-layers
    ];
  };

}
