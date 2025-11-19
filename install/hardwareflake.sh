nixos-generate-config --root /mnt # Creates /mnt/etc/nixos/hardware-configuration.nix
# Edit it: Add subvol/options as in prior example (vim/nano /mnt/etc/nixos/hardware-configuration.nix)

# Clone your repo (assumes git installed; if not, nix-shell -p git)
git clone YOUR_GIT_REPO_URL /mnt/etc/nixos # e.g., git@github.com:youruser/nixos-config.git
# If private: Setup SSH keys temporarily (copy from another machine or generate).

# Edit placeholders if needed (e.g., timezone, hashedPassword)
# Hash password: mkpasswd -m yescrypt YOUR_PASSWORD > /tmp/hash; paste into configuration.nix
nano /mnt/etc/nixos/configuration.nix # Or vim
