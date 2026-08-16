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

  systemd.services.readarr = {
    serviceConfig = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/cp -f /etc/readarr/config.xml /var/lib/readarr/config.xml"
      ];
    };
  };
}
