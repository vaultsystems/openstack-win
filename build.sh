IMAGE=windows-server-2012-r2.raw
FLOPPY=Autounattend.vfd
VIRTIO_ISO=virtio-win-0.1-74.iso
ISO=9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO

KVM=/usr/libexec/qemu-kvm
if [ ! -f "$KVM" ]; then
    KVM=/usr/bin/kvm
fi

#qemu-img create -f qcow2 -o preallocation=metadata $IMAGE 16G
rm $IMAGE
truncate --size=16G $IMAGE

$KVM -m 2048 -smp 2 -cdrom $ISO -drive file=$VIRTIO_ISO,index=3,media=cdrom -fda $FLOPPY $IMAGE -boot d -vga std -k en-us -vnc :1
