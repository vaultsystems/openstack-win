set -x
export GLANCE_NAME="Windows 2012 R2 autobuild $BUILD_NUMBER"
export ISO=/home/cdw/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO
time ./build.sh $ISO 1
glance image-create --name "$GLANCE_NAME" --property hw_cpu_sockets=1 --property jenkins_build=$BUILD_NUMBER --property description=$ISO --property os_type=windows --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi --property hw_qemu_guest_agent=yes --property os_require_quiesce=yes --disk-format raw --container-format bare --visibility public --file windows-server-2012-r2.raw
