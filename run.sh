IMAGE=windows-server-2012-r2.raw

KVM=/usr/libexec/qemu-kvm
if [ ! -f "$KVM" ]; then
    KVM=/usr/bin/kvm
fi

$KVM -m 4096 -smp 4 -drive file=$IMAGE -boot d -vga std -k en-us -vnc :1
