IMAGE=windows-server-2012-r2.raw

KVM=/usr/libexec/qemu-kvm
if [ ! -f "$KVM" ]; then
    KVM=/usr/bin/kvm
fi

$KVM -m 2048 -smp 2 -drive file=$IMAGE -boot d -vga std -k en-us -vnc :1
