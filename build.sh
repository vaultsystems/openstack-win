IMAGE=windows-server-2012-r2.raw
FLOPPY=Autounattend.vfd
VIRTIO=0.1.102
ISO=$1

wget --quiet -nc https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-$VIRTIO/virtio-win-$VIRTIO.iso -O virtio-win.iso

KVM=/usr/libexec/qemu-kvm
if [ ! -f "$KVM" ]; then
    KVM=/usr/bin/kvm
fi

if [ "$#" -ne 1 ]; then
    echo "Missing ISO file"
fi

#qemu-img create -f qcow2 -o preallocation=metadata $IMAGE 20G
truncate --size=0 $IMAGE
truncate --size=25G $IMAGE

$KVM -machine accel=kvm:tcg -machine pc-i440fx-1.5,accel=kvm,usb=off -cpu SandyBridge,+erms,+smep,+fsgsbase,+pdpe1gb,+rdrand,+f16c,+osxsave,+dca,+pcid,+pdcm,+xtpr,+tm2,+est,+smx,+vmx,+ds_cpl,+monitor,+dtes64,+pbe,+tm,+ht,+ss,+acpi,+ds,+vme -m 4096 -smp 4 -cdrom $ISO -drive file=virtio-win.iso,index=3,media=cdrom -fda $FLOPPY $IMAGE -boot d -vga std -k en-us -vnc :1
