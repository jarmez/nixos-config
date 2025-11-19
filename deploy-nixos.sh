#!/usr/bin/env bash
# deploy-nixos.sh: Automated NixOS install for jd-nix. Run from live USB.
# Prerequisites: Boot NixOS ISO, connect to internet (nmcli), insert Yubikey for enrollment.
# Steps: Partition, format, encrypt, mount, install, configure, reboot.
# Documentation: For sysadmins/enthusiasts—edit partitions if multi-disk. Logs to /tmp/deploy.log.

set -euo pipefail
LOG=/tmp/deploy.log
echo "Starting deployment. Logging to $LOG." | tee -a $LOG

# Step 1: Gather inputs
read -p "Enter hostname (default: jd-nix): " HOSTNAME
HOSTNAME=${HOSTNAME:-jd-nix}
read -p "Enter username (default: james): " USERNAME
USERNAME=${USERNAME:-james}
read -s -p "Enter user password: " PASSWORD
echo
read -s -p "Enter LUKS password (for fallback): " LUKS_PASS
echo
read -p "Enter disk (default: /dev/nvme0n1): " DISK
DISK=${DISK:-/dev/nvme0n1}
echo "Using: Host $HOSTNAME, User $USERNAME, Disk $DISK" | tee -a $LOG

# Step 2: Partition (EFI 512M, LUKS rest)
echo "Partitioning $DISK..." | tee -a $LOG
sgdisk -Z $DISK
sgdisk -n 1:0:+512M -t 1:ef00 $DISK  # EFI
sgdisk -n 2:0:0 -t 2:8300 $DISK      # Root (LUKS)
sgdisk -p $DISK | tee -a $LOG

# Step 3: Encrypt and format
echo "Setting up LUKS..." | tee -a $LOG
echo -n "$LUKS_PASS" | cryptsetup luksFormat --type luks2 ${DISK}p2 -
echo -n "$LUKS_PASS" | cryptsetup open ${DISK}p2 root -
mkfs.vfat -F32 ${DISK}p1
mkfs.btrfs -f /dev/mapper/root
mount /dev/mapper/root /mnt
btrfs subvolume create /mnt/@ 
btrfs subvolume create /mnt/@home
umount /mnt
mount -o compress=zstd,subvol=@ /dev/mapper/root /mnt
mkdir /mnt/home
mount -o compress=zstd,subvol=@home /dev/mapper/root /mnt/home
mkdir /mnt/boot
mount ${DISK}p1 /mnt/boot

# Step 4: Clone config and install
echo "Cloning config (assume your Git repo; edit URL)..." | tee -a $LOG
mkdir -p /mnt/etc/nixos
git clone https://github.com/yourusername/nixos-config.git /mnt/etc/nixos  # Replace with your repo URL
cd /mnt/etc/nixos
nixos-generate-config --root /mnt  # Generates hardware.nix
# Edit configuration.nix if needed (e.g., UUIDs from blkid)
nixos-install --flake .#$HOSTNAME --root /mnt
echo "Install complete. Enrolling TPM/Yubikey..." | tee -a $LOG
chroot /mnt /run/current-system/sw/bin/systemd-cryptenroll --tpm2-device=auto --fido2-device=auto ${DISK}p2
chroot /mnt /run/current-system/sw/bin/passwd $USERNAME <<< "$PASSWORD"$'\n'"$PASSWORD"

# Step 5: Reboot
echo "Deployment done. Rebooting..." | tee -a $LOG
umount -R /mnt
cryptsetup close root
reboot
