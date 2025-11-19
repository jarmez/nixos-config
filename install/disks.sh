DISK=/dev/nvme0n1 # Confirm with lsblk!

# Partition
parted $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MiB 1GiB
parted $DISK -- set 1 esp on
parted $DISK -- mkpart root 1GiB -34GiB
parted $DISK -- mkpart swap -34GiB 100%

# Format EFI
mkfs.fat -F 32 -n EFI ${DISK}p1

# Encrypt root (LUKS2 for FIDO2/TPM)
cryptsetup luksFormat --type luks2 ${DISK}p2 # Enter passphrase (initial; enroll later)
cryptsetup open ${DISK}p2 enc

# Encrypt swap (random key for security; regenerated on boot if needed)
cryptsetup luksFormat --type luks2 ${DISK}p3
cryptsetup open ${DISK}p3 swap

# Format BTRFS
mkfs.btrfs -L nixroot /dev/mapper/enc
mount /dev/mapper/enc /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt

# Mount with options
mount -o subvol=@,compress=zstd:3,noatime,ssd,space_cache=v2 /dev/mapper/enc /mnt
mkdir -p /mnt/{home,nix,boot}
mount -o subvol=@home,compress=zstd:3,noatime,ssd,space_cache=v2 /dev/mapper/enc /mnt/home
mount -o subvol=@nix,compress=zstd:3,noatime,ssd,space_cache=v2,nodatacow /dev/mapper/enc /mnt/nix
mount ${DISK}p1 /mnt/boot

# Swap
mkswap -L swap /dev/mapper/swap
swapon /dev/mapper/swap # Optional for live env
