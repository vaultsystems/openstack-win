set -x
export GLANCE_NAME="Windows 2012 R2 autobuild $BUILD_NUMBER"
export ISO=/home/cdw/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO
./create-autounattend-floppy.sh
time ./build.sh $ISO
glance image-create --name "$GLANCE_NAME" --property description=$ISO --property os_type=windows --disk-format raw --container-format bare --is-public true < windows-server-2012-r2.raw
