#!/bin/bash
#Bandido kernel build script. fbs @ xda

#Set CROSS_COMPILE to your gcc path.
#It should end in the last "-" of the gcc's binary full path
export CROSS_COMPILE=/home/me/x-tools/14.1forsize/bin/aarch64-linux-gnu-

export ARCH=arm64
DATE_START=$(date +"%s")
IMAGE="out/arch/arm64/boot/Image"
DTB="out/arch/arm64/boot/dtb.img"

mkdir -p out
rm $IMAGE &> /dev/null

CPU=$(($(nproc) - 1))

make -C $(pwd) O=$(pwd)/out bandido_defconfig
make -j$CPU -C $(pwd) O=$(pwd)/out |tee ../bandj7.log

if [[ -f "$IMAGE" ]] && [[ -f "$DTB" ]]; then
        STATE=`adb get-state`
        if [[ $STATE != "recovery" ]]; then
                adb reboot recovery
        fi
        KERNELZIP="bandido-kernel-$(date +"%Y%m%d%H%M").zip"

        rm AnyKernel3/*Image* > /dev/null 2>&1
        rm AnyKernel3/*.zip > /dev/null 2>&1
	rm AnyKernel3/dt* > /dev/null 2>&1

        cp $IMAGE AnyKernel3
	cp $DTB AnyKernel3/dt
        cd AnyKernel3

        zip -r9 $KERNELZIP .

        DATE_END=$(date +"%s")
        DIFF=$(($DATE_END - $DATE_START))

        echo -e "\nTime elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.\n"
        adb wait-for-recovery
        adb push $KERNELZIP /sdcard/
else
        echo -e "ERROR\n"
fi
