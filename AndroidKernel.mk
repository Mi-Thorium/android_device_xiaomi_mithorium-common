LOCAL_PATH := $(call my-dir)

#----------------------------------------------------------------------
# Compile Linux Kernel
#----------------------------------------------------------------------
KERNEL_DEFCONFIG := $(TARGET_KERNEL_CONFIG)
ifeq ($(TARGET_KERNEL_VERSION), 4.19)
   include device/qcom/kernelscripts/kernel_definitions.mk
else
ifeq ($(TARGET_KERNEL_VERSION), 4.9)
   ifeq ($(TARGET_KERNEL_SOURCE),)
      TARGET_KERNEL_SOURCE := kernel
   endif

DTC := $(HOST_OUT_EXECUTABLES)/dtc$(HOST_EXECUTABLE_SUFFIX)
# ../../ prepended to paths because kernel is at ./kernel/msm-x.x
TEMP_TOP=$(shell pwd)
#TARGET_KERNEL_MAKE_ENV := DTC_EXT=$(TEMP_TOP)/$(DTC)
TARGET_KERNEL_MAKE_ENV := CONFIG_BUILD_ARM64_DT_OVERLAY=y
TARGET_KERNEL_MAKE_ENV += HOSTCC=$(TEMP_TOP)/prebuilts/clang/host/linux-x86/proton-clang/bin/clang
TARGET_KERNEL_MAKE_ENV += HOSTAR=$(TEMP_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-ar
TARGET_KERNEL_MAKE_ENV += HOSTLD=$(TEMP_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-ld
TARGET_KERNEL_MAKE_ENV += HOSTCFLAGS="-I/usr/include -I/usr/include/x86_64-linux-gnu -L/usr/lib -L/usr/lib/x86_64-linux-gnu -fuse-ld=lld"
TARGET_KERNEL_MAKE_ENV += HOSTLDFLAGS="-L/usr/lib -L/usr/lib/x86_64-linux-gnu -fuse-ld=lld"

# Add back threads, ninja cuts this to $(nproc)/2
TARGET_KERNEL_MAKE_ENV += -j$(shell prebuilts/tools-lineage/$(HOST_PREBUILT_TAG)/bin/nproc --all)

#Enable llvm support for kernel
KERNEL_LLVM_SUPPORT := true

#Enable sd-llvm suppport for kernel
KERNEL_SD_LLVM_SUPPORT := true
SDCLANG_PATH := $(TEMP_TOP)/prebuilts/clang/host/linux-x86/proton-clang/bin/

TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(shell pwd)/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
TARGET_KERNEL_CROSS_COMPILE_ARM32_PREFIX := $(shell pwd)/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androidkernel-
TARGET_USES_UNCOMPRESSED_KERNEL := false

KERNEL_MODULES_INSTALL := vendor
TARGET_KERNEL_APPEND_DTB := true

include $(TARGET_KERNEL_SOURCE)/AndroidKernel.mk
$(TARGET_PREBUILT_KERNEL): $(DTC)

$(INSTALLED_KERNEL_TARGET): $(TARGET_PREBUILT_KERNEL) | $(ACP)
	$(transform-prebuilt-to-target)
endif
endif

#----------------------------------------------------------------------
# Generate device tree overlay image (dtbo.img)
#----------------------------------------------------------------------
ifneq ($(strip $(TARGET_NO_KERNEL)),true)
ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DTBO)),true)

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)

# Most specific paths must come first in possible_dtbo_dirs
possible_dtbo_dirs = $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/dts $(KERNEL_OUT)/arch/arm/boot/dts
$(shell mkdir -p $(possible_dtbo_dirs))
dtbo_dir = $(firstword $(wildcard $(possible_dtbo_dirs)))
dtbo_objs = $(shell find $(dtbo_dir) -name \*.dtbo)

define build-dtboimage-target
    $(call pretty,"Target dtbo image: $(BOARD_PREBUILT_DTBOIMAGE)")
    $(hide) $(MKDTIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $(dtbo_objs)
    $(hide) chmod a+r $@
endef

# Definition of BOARD_PREBUILT_DTBOIMAGE is in AndroidBoardCommon.mk
# so as to ensure it is defined well in time to set the dependencies on
# BOARD_PREBUILT_DTBOIMAGE
$(BOARD_PREBUILT_DTBOIMAGE): $(MKDTIMG) $(INSTALLED_KERNEL_TARGET)
	$(build-dtboimage-target)

endif
endif