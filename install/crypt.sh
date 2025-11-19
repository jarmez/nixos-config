# Bind mounts
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /run /mnt/run # For dbus if needed
chroot /mnt /bin/bash

# Inside chroot (as root):
# Secure Boot keys (Lanzaboote signs kernels)
sbctl create-keys --dir /etc/secureboot
sbctl enroll-keys # Enrolls Microsoft keys + yours; reboot to BIOS to enable Secure Boot after.

# Encryption enrollment (wipe default slots first if needed)
systemd-cryptenroll --wipe-slot=0 --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2 # TPM auto (binds to Secure Boot)
echo "Insert YubiKey and press Enter"
read
systemd-cryptenroll --fido2-device=auto --fido2-with-pin=true /dev/nvme0n1p2 # FIDO2 fallback (touch + PIN)
# Password remains as fallback (set during luksFormat).

exit # Exit chroot
umount -R /mnt
swapoff -a
cryptsetup close enc
cryptsetup close swap
reboot
