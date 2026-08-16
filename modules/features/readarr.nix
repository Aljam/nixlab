# modules/features/readarr.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.readarr = {
    enable = true;
    group = "media";
  };

  # Generate config.xml declaratively with correct port
  environment.etc."readarr/config.xml".text = ''
    <Config>
      <BindAddress>${bindAddr}</BindAddress>
      <Port>8787</Port>
      <SslPort>6868</SslPort>
      <EnableSsl>False</EnableSsl>
      <LaunchBrowser>True</LaunchBrowser>
      <ApiKey>71a5fa0bb47d49c88c263cc4954f3b88</ApiKey>
      <AuthenticationMethod>Forms</AuthenticationMethod>
      <AuthenticationRequired>Enabled</AuthenticationRequired>
      <Branch>develop</Branch>
      <LogLevel>debug</LogLevel>
      <SslCertPath></SslCertPath>
      <SslCertPassword></SslCertPassword>
      <UrlBase></UrlBase>
      <InstanceName>Readarr</InstanceName>
    </Config>
  '';

  # Ensure correct permissions and copy config on every start
  systemd.services.readarr = {
    serviceConfig = {
      ExecStartPre = [
        # Fix directory permissions
        "${pkgs.coreutils}/bin/chown -R readarr:media /var/lib/readarr",
        "${pkgs.coreutils}/bin/chmod 775 /var/lib/readarr",
        # Copy config
        "${pkgs.coreutils}/bin/cp -f /etc/readarr/config.xml /var/lib/readarr/config.xml",
        "${pkgs.coreutils}/bin/chown readarr:media /var/lib/readarr/config.xml",
      ];
    };
  };
}
