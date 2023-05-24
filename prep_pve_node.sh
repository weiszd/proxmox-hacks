#!/bin/bash

echo "#deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise" > /etc/apt/sources.list.d/pve-enterprise.list
echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-no-enterprise.list
apt update
apt-get -y dist-upgrade
#reboot

#enable nested virtualization

if grep -q "Y" "/sys/module/kvm_intel/parameters/nested"; then
  echo "Nested virtualization is already enabled."
else
  echo "options kvm-intel nested=Y" > /etc/modprobe.d/kvm-intel.conf
fi

apt install -y mc byobu mstflint rdma-core ibverbs-utils infiniband-diags network-manager openvswitch-switch net-tools parallel micro mstflint
byobu-enable
echo 'if [ -n "$BYOBU_BACKEND" ]; then $BYOBU_BACKEND source $BYOBU_PREFIX/share/byobu/keybindings/f-keys.tmux.disable && $BYOBU_BACKEND source $BYOBU_PREFIX/share/byobu/keybindings/mouse.tmux.disable 2>/dev/null; fi' >>~/.bashrc
byobu-ctrl-a screen

#mc
mc -F
echo 'SELECTED_EDITOR="/usr/bin/mcedit"' > ~/.selected_editor
echo "alias mc='mc -x'" >> ~/.bashrc
sed -i 's/auto_save_setup_panels=false/auto_save_setup_panels=true/g' ~/.config/mc/ini
sed -i 's/navigate_with_arrows=false/navigate_with_arrows=true/g' ~/.config/mc/ini

echo -e 'if [[ $PROMPT_COMMAND != *"history -a"* ]]; then\n    export PROMPT_COMMAND="history -a; history -c; history -r;"\nfi' >> ~/.bashrc

wget -O ~/.inputrc https://github.com/weiszd/proxmox-hacks/raw/main/.inputrc

#Enable SRIOV support in kernel
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt iommu.passthrough=1"/g' /etc/default/grub

echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" >> /etc/modprobe.d/mlx4_core.conf
echo "options mlx4_core port_type_array=1,2 num_vfs=0,0,8 probe_vf=0,0,2 log_num_mgm_entry_size=-1 debug_level=0 " >> /etc/modprobe.d/mlx4_core.conf

lspci |grep "\[ConnectX-3" | awk '{print $1}' |xargs -I{} mstconfig -y -d {} set SRIOV_EN=1 NUM_OF_VFS=15

update-grub
update-initramfs -u -k all
#reboot

echo -e 'mlx4_core\nmlx4_ib\nib_umad\nib_uverbs\nib_ipoib\nxprtrdma\nvfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd' >> /etc/modules



