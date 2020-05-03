#!/bin/bash
set -ex
# In gigabytes
PI_TARGET_SIZE=${PI_TARGET_SIZE:-25}
# Set up dependencies
command -v unxz || sudo apt-get install xz-utils
command -v kpartx || sudo apt install kpartx
command -v parted || sudo apt-get install parted
# Setup qemu
command -v qemu-system-arm || sudo apt-get install qemu-system qemu-user-static
# Download the base images
if [ ! -f ubuntu-arm64.img.xz ] &&  [ ! -f ubuntu-arm64.img ]; then
  wget http://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz?_ga=2.44224356.1107789398.1588456160-1469204870.1587264737 -O ubuntu-arm64.img.xz
fi
if [ ! -f ubuntu-arm64.img ]; then
  unxz ubuntu-arm64.img.xz
fi
# Customize the image
if [ -f ubuntu-arm64-customized.img ]; then
  rm ubuntu-arm64-customized.img
fi
cp ubuntu-arm64.img ubuntu-arm64-customized.img
mkdir -p ubuntu-image
partition=$(sudo kpartx -av ubuntu-arm64-customized.img  | cut -f 3 -d " " | tail -n 1)
sudo mount  /dev/mapper/${partition} ubuntu-image
sudo mkdir -p ubuntu-image/root/.ssh
sudo cp ~/.ssh/authorized_keys ubuntu-image/root/.ssh/
sudo cp ~/.ssh/known_hosts ubuntu-image/root/.ssh/
sync
sleep 5
# Extend the image
sudo umount /dev/mapper/${partition}
sync
sleep 1
sudo e2fsck -f /dev/mapper/${partition}
sudo kpartx -dv ubuntu-arm64-customized.img
sync
sleep 5
dd if=/dev/zero bs=1G count=$((${PI_TARGET_SIZE}+1)) of=./ubuntu-arm64-customized.img conv=sparse,notrunc oflag=append
sudo parted ubuntu-arm64-customized.img resizepart 2 ${PI_TARGET_SIZE}g
partition=$(sudo kpartx -av ubuntu-arm64-customized.img  | cut -f 3 -d " " | tail -n 1)
sudo e2fsck -f /dev/mapper/${partition}
sudo resize2fs /dev/mapper/${partition}
sync
sleep 5
sudo mount  /dev/mapper/${partition} ubuntu-image
sudo mount --bind /dev ubuntu-image/dev/
sudo mount --bind /sys ubuntu-image/sys/
sudo mount --bind /proc ubuntu-image/proc/
sudo mount --bind /dev/pts ubuntu-image/dev/pts
sudo rm ubuntu-image/etc/resolv.conf
sudo cp /etc/resolv.conf ubuntu-image/etc/resolv.conf
#cp ubuntu-image/etc/ld.so.preload ubuntu-image/etc/ld.so.preload.back
#sed -i 's/^/#CHROOT /g' ubuntu-image/etc/ld.so.preload
sudo cp /usr/bin/qemu-arm-static ubuntu-image/usr/bin/
sudo cp update_pi.sh ubuntu-image/
sudo chroot ubuntu-image/ /update_pi.sh
sudo cp 50-cloud-init.yaml.custom ubuntu-image/etc/netplan/
#sudo umount ubuntu-image/sys ubuntu-image/proc ubuntu-image/dev/pts ubuntu-image/dev ubuntu-image
#sudo kpartx -dv ubuntu-arm64-customized.img
#sync
#sleep 5
#echo "Done!"
