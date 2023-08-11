#!/bin/bash
export CROSS_COMPILE=/root/arm-gnu-toolchain-12.2.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
export ARCH=arm64

DATE_START=$(date +"%s")
IMAGE="out/arch/arm64/boot/Image"
DTB="out/arch/arm64/boot/dtb.img"

mkdir -p out
rm $IMAGE &> /dev/null

CPU=$(($(nproc) - 1))

make -C $(pwd) O=$(pwd)/out lineageos_j7elte_defconfig
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
