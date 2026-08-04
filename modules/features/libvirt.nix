{ config, pkgs, ... }:

{
  # --- Virtualisation & KVM ---
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
  # Ensure it doesn't force conflicting network rules if you manage them elsewhere
  virtualisation.libvirtd.onBoot = "ignore";
  virtualisation.libvirtd.onShutdown = "shutdown";

  # GUI frontend for libvirtd 
  # (If you ever use this module on a headless server, you can override this to false)
  programs.virt-manager.enable = true;

  # --- Default Libvirt Network XML ---
  environment.etc."libvirt/qemu/networks/default.xml".text = ''
    <network>
      <name>default</name>
      <bridge name="virbr0"/>
      <forward mode='nat'/>
      <ip address='172.16.56.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='172.16.56.2' end='172.16.56.254'/>
          <host mac='52:54:00:12:34:56' name='virtualmachine' ip='172.16.56.10'/>
        </dhcp>
      </ip>
    </network>
  '';

  # --- Auto-start Libvirt Network ---
  system.activationScripts.libvirt-network-start = {
    deps = [ "users" ];
    text = ''
      export VIRSH_DEFAULT_CONNECT_URI="qemu:///system"
      /run/current-system/sw/bin/sleep 2
      if ! /run/current-system/sw/bin/virsh net-list --all | grep -q "default"; then
        /run/current-system/sw/bin/virsh net-define /etc/libvirt/qemu/networks/default.xml
      fi
      /run/current-system/sw/bin/virsh net-start default || true
      /run/current-system/sw/bin/virsh net-autostart default || true
    '';
  };
}
