IMAGE=windows-server-2012-r2.raw
FLOPPY=Autounattend.vfd
VIRTIO=virtio-win-0.1-94
ISO=$1

wget -nc http://alt.fedoraproject.org/pub/alt/virtio-win/archives/$VIRTIO/$VIRTIO.iso

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

$KVM -machine pc-i440fx-trusty,accel=kvm,usb=off -cpu SandyBridge,+erms,+smep,+fsgsbase,+pdpe1gb,+rdrand,+f16c,+osxsave,+dca,+pcid,+pdcm,+xtpr,+tm2,+est,+smx,+vmx,+ds_cpl,+monitor,+dtes64,+pbe,+tm,+ht,+ss,+acpi,+ds,+vme -m 4096 -smp 4 -cdrom $ISO -drive file=$VIRTIO.iso,index=3,media=cdrom -fda $FLOPPY $IMAGE -boot d -vga std -k en-us -vnc :1
