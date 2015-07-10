Windows 2012 Unattended Setup
===============================

Tools to automate the creation of a Windows image for OpenStack, supporting KVM, Hyper-V, ESXi and more.

Note: we consider that target system is x64



### Creating Image on KVM


You'll need your Windows installation ISO and the virtio driver ISO:

	http://ftp.sleepgate.ru/drivers/NET/virtio-win/virtio-win-0.1-81.iso

Then run:

	./build.sh

Now you can just wait for the script to exit. You can also connect to the VM via VNC on port 5901 to check
the status, no user interaction is required.

Note: if you plan to connect remotely via VNC, make sure that the KVM host firewall allows traffic
on this port, e.g.:

    iptables -I INPUT -p tcp --dport 5901 -j ACCEPT

On every change of Autounattended.xml we need to recreate floppy image:

	./create-autounattend-floppy.sh

Original Toolbelt can be found at https://github.com/cloudbase/windows-openstack-imaging-tools
