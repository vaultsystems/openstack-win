IMAGE=windows-server-2012-r2.raw
FLOPPY=Autounattend.vfd
VIRTIO=virtio-win-0.1.118-2
ISO=$1
wget -N https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/$VIRTIO/virtio-win.iso
./convert_virtio_iso.sh virtio-win.iso virtio-converted.iso
mkisofs -J -r -o autounattend.iso config

KVM=/usr/libexec/qemu-kvm
if [ ! -f "$KVM" ]; then
    KVM=/usr/bin/kvm
fi

#qemu-img create -f qcow2 -o preallocation=metadata $IMAGE 20G
truncate --size=0 $IMAGE
truncate --size=25G $IMAGE

$KVM -machine accel=kvm:tcg -machine pc-i440fx-1.5,accel=kvm,usb=off -cpu SandyBridge,+erms,+smep,+fsgsbase,+pdpe1gb,+rdrand,+f16c,+osxsave,+dca,+pcid,+pdcm,+xtpr,+tm2,+est,+smx,+vmx,+ds_cpl,+monitor,+dtes64,+pbe,+tm,+ht,+ss,+acpi,+ds,+vme -m 4096 -smp 4 -cdrom $ISO -drive file=virtio-converted.iso,index=3,media=cdrom -drive file=autounattend.iso,index=1,media=cdrom -drive format=raw,file=$IMAGE -boot d -vga std -k en-us -vnc :$2
