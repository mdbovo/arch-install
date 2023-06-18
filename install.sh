#!/bin/bash
set -e

timedatectl set-ntp true

lsblk
read -p "Enter drive to installl on (eg. nvme0n1): " INSTALL_DRIVE

cfdisk /dev/$INSTALL_DRIVE
sleep 5

lsblk
read -p "Enter EFI, swap, and root partition-suffix in order seperated by spaces (eg. p1 p2 p3 for nvme or 1 2 3 for sata): " EFI_PARTITION_SUFFIX SWAP_PARTITION_SUFFIX ROOT_PARTITION_SUFFIX 

EFI_PARTITION=$INSTALL_DRIVE$EFI_PARTITION_SUFFIX
SWAP_PARTITION=$INSTALL_DRIVE$SWAP_PARTITION_SUFFIX
ROOT_PARTITION=$INSTALL_DRIVE$ROOT_PARTITION_SUFFIX

mkfs.ext4 /dev/$ROOT_PARTITION
mkfs.vfat /dev/$EFI_PARTITION
mkswap /dev/$SWAP_PARTITION

mount /dev/$ROOT_PARTITION /mnt
mkdir /mnt/efi
mount /dev/$EFI_PARTITION /mnt/efi
swapon /dev/$SWAP_PARTITION

reflector --verbose --latest 30 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware man-db man-pages texinfo grub efibootmgr networkmanager git nano virtualbox-guest-utils

genfstab -U /mnt >> /mnt/etc/fstab

cp ./arch-install/chroot.sh /mnt
arch-chroot /mnt ./chroot.sh
rm -f /mnt/chroot.sh

reboot
