#!/bin/bash
export CROSS_COMPILE=/root/arm-gnu-toolchain-12.2.rel1-x86_64-aarch64-none-elf/bin/aarch64-none-elf-
export ARCH=arm64

DATE_START=$(date +"%s")
IMAGE="out/arch/arm64/boot/Image.gz"
DTB="out/dtb.img"

mkdir -p out
rm $IMAGE &> /dev/null
CPU=$(($(nproc) - 1))

make -C $(pwd) O=$(pwd)/out lineageos_j7elte_defconfig
make -j$CPU -C $(pwd) O=$(pwd)/out

if [[ -f "$IMAGE" ]]; then
        STATE=`adb get-state`
        if [[ $STATE != "recovery" ]]; then
                adb reboot recovery
        fi
        KERNELZIP="bandido-kernel-$(date +"%Y%m%d%H%M").zip"
        cat out/arch/arm64/boot/dts/*.dtb > $DTB
        rm AnyKernel3/zImage > /dev/null 2>&1
        rm AnyKernel3/*.zip > /dev/null 2>&1
        cp $IMAGE AnyKernel3/Image.gz
        cp $DTB AnyKernel3/dtb
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
