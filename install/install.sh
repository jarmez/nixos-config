nixos-install --flake /mnt/etc/nixos#yoga-nix --no-root-passwd
# This pulls from unstable, applies configs (systemd-boot, AppArmor, Podman, etc.).
# If errors: Check flake.lock (git pull if needed); ensure allowUnfree=true.
