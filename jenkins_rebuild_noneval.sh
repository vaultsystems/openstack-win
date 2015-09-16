set -x
export GLANCE_NAME="Windows 2012 R2 NON-EVAL"
export ISO=/home/cdw/SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-3_MLF_X19-53588.ISO
./create-autounattend-floppy.sh
time ./build.sh $ISO
glance image-list | grep "$GLANCE_NAME" | awk '{ print $2}'| xargs --no-run-if-empty -L1 glance image-delete
glance image-create --name "$GLANCE_NAME" --property jenkins_build=$BUILD_NUMBER --property description=$ISO --property os_type=windows --disk-format raw --container-format bare --is-public true < windows-server-2012-r2.raw
