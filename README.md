Windows 2012 Unattended Setup
===============================

Tools to automate the creation of a Windows image for OpenStack, supporting KVM, Hyper-V, ESXi and more.

Note: we consider that target system is x64

### Creating Image on KVM

	./build.sh <WINDOWS.ISO> <VNCPORT>

e.g.:

  ./build.sh 9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO 1

for Windows 2012R2 and VNC port 5901.

Now you can just wait for the script to exit. You can also connect to the VM via VNC on port 5901 to check
the status, no user interaction is required.

Note: if you plan to connect remotely via VNC, make sure that the KVM host firewall allows traffic
on this port, e.g.:

    iptables -I INPUT -p tcp --dport 5901 -j ACCEPT

Original Toolbelt can be found at https://github.com/cloudbase/windows-openstack-imaging-tools
