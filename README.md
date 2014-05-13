Windows 2012 Unattended Setup
===============================

Tools to automate the creation of a Windows image for OpenStack, supporting KVM, Hyper-V, ESXi and more.

Note: we consider that target system is x64 



### Creating Image on KVM


Download the VirtIO tools ISO, e.g. from:
http://alt.fedoraproject.org/pub/alt/virtio-win/latest/images/bin/

You'll need also your Windows installation ISO. In the following example we'll use a Windows Server 2012 R2
evaluation.

    IMAGE=windows-server-2012-r2.qcow2
    FLOPPY=Autounattend.vfd
    VIRTIO_ISO=virtio-win-0.1-52.iso
    ISO=9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO

    KVM=/usr/libexec/qemu-kvm
    if [ ! -f "$KVM" ]; then
        KVM=/usr/bin/kvm
    fi

    qemu-img create -f qcow2 -o preallocation=metadata $IMAGE 16G

    $KVM -m 2048 -smp 2 -cdrom $ISO -drive file=$VIRTIO_ISO,index=3,media=cdrom -fda $FLOPPY $IMAGE -boot d -vga std -k en-us -vnc :1

Now you can just wait for the KVM command to exit. You can also connect to the VM via VNC on port 5901 to check
the status, no user interaction is required.

Note: if you plan to connect remotely via VNC, make sure that the KVM host firewall allows traffic
on this port, e.g.:

    iptables -I INPUT -p tcp --dport 5901 -j ACCEPT

On every change of Autounattended.xml we need to recreate floppy image:

	./create-autounattend-floppy.sh

Original Toolbelt can be found at https://github.com/cloudbase/windows-openstack-imaging-tools
