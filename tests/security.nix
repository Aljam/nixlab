{ lib, config }:

let
  assertions = [
    {
      assertion = config.security.sudo.enable == false
        || config.security.sudo.wheelNeedsPassword;
      message = "Security test: sudo should require a password when enabled.";
    }
    {
      assertion = config.services.openssh.enable == false
        || config.services.openssh.settings.PasswordAuthentication == false;
      message = "Security test: SSH password authentication should be disabled.";
    }
  ];
in
{
  inherit assertions;
}
