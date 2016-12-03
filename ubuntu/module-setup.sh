#!/bin/bash

# called by dracut
check() {
    return 0
}

# called by dracut
depends() {
    return 0
}

# called by dracut
installkernel() {
    instmods squashfs loop overlay
}

# called by dracut
install() {
    inst_multiple umount rsync df free tail tune2fs
    inst_hook pre-pivot 99 "$moddir/mount-rootfs.sh"
}