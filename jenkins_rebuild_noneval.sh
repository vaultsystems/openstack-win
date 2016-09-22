set -x
export GLANCE_NAME="Windows 2012 R2 NON-EVAL"
export ISO=/home/cdw/SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-3_MLF_X19-53588.ISO
time ./build.sh $ISO 2
glance image-list | grep "$GLANCE_NAME" | awk '{ print $2}'| xargs --no-run-if-empty -L1 glance image-delete
glance image-create --name "$GLANCE_NAME" --property hw_cpu_sockets=1 --property jenkins_build=$BUILD_NUMBER --property description=$ISO --property os_type=windows --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi --property hw_qemu_guest_agent=yes --property os_require_quiesce=yes --disk-format raw --container-format bare --visibility public --file windows-server-2012-r2.raw
