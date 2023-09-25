#
# Copyright (C) 2017-2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

COMMON_PATH := device/xiaomi/mithorium-common

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53

# Build
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# Kernel - Common
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_CMDLINE := androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 androidboot.bootdevice=7824900.sdhci loop.max_part=7
BOARD_KERNEL_CMDLINE += androidboot.usbconfigfs=true androidboot.init_fatal_reboot_target=recovery printk.devkmsg=on
BOARD_KERNEL_CMDLINE += console=ttyMSM0,115200,n8 androidboot.console=ttyMSM0
ifeq ($(TARGET_BOARD_PLATFORM),msm8937)
    ifeq ($(TARGET_KERNEL_VERSION),4.9)
        BOARD_KERNEL_CMDLINE += earlycon=msm_serial_dm,0x78b0000
    else ifeq ($(TARGET_KERNEL_VERSION),4.19)
        BOARD_KERNEL_CMDLINE += earlycon=msm_hsl_uart,0x78b0000
    endif
else ifeq ($(TARGET_BOARD_PLATFORM),msm8953)
    ifeq ($(TARGET_KERNEL_VERSION),4.9)
        BOARD_KERNEL_CMDLINE += earlycon=msm_serial_dm,0x78af000
    else ifeq ($(TARGET_KERNEL_VERSION),4.19)
        BOARD_KERNEL_CMDLINE += earlycon=msm_hsl_uart,0x78af000
    endif
endif
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
BOARD_KERNEL_PAGESIZE :=  2048
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01000000 --tags_offset 0x00000100
TARGET_KERNEL_ADDITIONAL_FLAGS := LLVM=1

# Kernel - Mi-Thorium
ifeq ($(TARGET_USES_MITHORIUM_KERNEL),true)
TARGET_KERNEL_SOURCE := kernel/xiaomi/mithorium-$(TARGET_KERNEL_VERSION)/kernel

TARGET_KERNEL_CONFIG := \
    vendor/$(TARGET_BOARD_PLATFORM)-perf_defconfig \
    vendor/common.config \
    vendor/feature/android-12.config \
    vendor/feature/erofs.config \
    vendor/feature/exfat.config \
    vendor/feature/kprobes.config \
    vendor/feature/lmkd.config

TARGET_KERNEL_RECOVERY_CONFIG := \
    vendor/$(TARGET_BOARD_PLATFORM)-perf_defconfig \
    vendor/common.config \
    vendor/feature/erofs.config \
    vendor/feature/exfat.config \
    vendor/feature/ntfs.config \
    vendor/feature/no-camera-stack.config \
    vendor/feature/no-wlan-driver.config

ifeq ($(PRODUCT_SET_DEBUGFS_RESTRICTIONS),true)
TARGET_KERNEL_CONFIG += \
    vendor/debugfs.config
endif

ifeq ($(TARGET_KERNEL_VERSION),4.9)
TARGET_KERNEL_CONFIG += \
    vendor/feature/uclamp.config
else ifeq ($(TARGET_KERNEL_VERSION),4.19)
TARGET_KERNEL_CONFIG += \
    vendor/feature/wireguard.config
endif

ifneq ($(shell grep CONFIG_KSU_STATIC_HOOKS $(TARGET_KERNEL_SOURCE)/techpack/KernelSU/kernel/ksu.c),)
TARGET_KERNEL_CONFIG += \
    vendor/feature/ksu_static_hooks.config
endif
endif

$(call soong_config_set,MITHORIUM_KERNEL,DEVICE,$(TARGET_DEVICE))

# ANT
BOARD_ANT_WIRELESS_DEVICE := "vfs-prerelease"

# Audio
BOARD_USES_ALSA_AUDIO := true
USE_XML_AUDIO_POLICY_CONF := 1
BOARD_SUPPORTS_SOUND_TRIGGER := true
AUDIO_USE_DEEP_AS_PRIMARY_OUTPUT := false
AUDIO_FEATURE_ENABLED_HIFI_AUDIO := true
AUDIO_FEATURE_ENABLED_VBAT_MONITOR := true
AUDIO_FEATURE_ENABLED_NT_PAUSE_TIMEOUT := true
AUDIO_FEATURE_ENABLED_ANC_HEADSET := true
AUDIO_FEATURE_ENABLED_CUSTOMSTEREO := true
AUDIO_FEATURE_ENABLED_FLUENCE := true
AUDIO_FEATURE_ENABLED_HDMI_EDID := true
AUDIO_FEATURE_ENABLED_EXT_HDMI := false
AUDIO_FEATURE_ENABLED_HFP := true
AUDIO_FEATURE_ENABLED_INCALL_MUSIC := true
AUDIO_FEATURE_ENABLED_MULTI_VOICE_SESSIONS := true
AUDIO_FEATURE_ENABLED_KPI_OPTIMIZE := true
AUDIO_FEATURE_ENABLED_SPKR_PROTECTION := true
AUDIO_FEATURE_ENABLED_ACDB_LICENSE := true
AUDIO_FEATURE_ENABLED_DEV_ARBI := false
MM_AUDIO_ENABLED_FTM := true
TARGET_USES_QCOM_MM_AUDIO := true
AUDIO_FEATURE_ENABLED_SOURCE_TRACKING := true
BOARD_SUPPORTS_QAHW := false
AUDIO_FEATURE_ENABLED_DYNAMIC_LOG := false
AUDIO_FEATURE_ENABLED_SND_MONITOR := true
AUDIO_FEATURE_ENABLED_SVA_MULTI_STAGE := true
AUDIO_FEATURE_ENABLED_DLKM := false
AUDIO_FEATURE_ENABLED_HAL_V7 := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := $(TARGET_BOARD_PLATFORM)
TARGET_NO_BOOTLOADER := true

# Camera
BOARD_QTI_CAMERA_32BIT_ONLY := true
TARGET_SUPPORT_HAL1 := false
TARGET_TS_MAKEUP := true

# Display
TARGET_USES_GRALLOC1 := true
TARGET_USES_HWC2 := true
TARGET_USES_ION := true

ifneq ($(TARGET_USES_Q_DISPLAY_STACK),true)
TARGET_USES_GRALLOC4 := true
TARGET_USES_QTI_MAPPER_2_0 := true
TARGET_USES_QTI_MAPPER_EXTENSIONS_1_1 := true
endif

# FM
BOARD_HAVE_QCOM_FM := true
TARGET_QCOM_NO_FM_FIRMWARE := true

# GPS
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := default
LOC_HIDL_VERSION := 4.1

# Filesystem
TARGET_FS_CONFIG_GEN := $(COMMON_PATH)/config.fs

# Filesystem - EROFS
ifeq ($(TARGET_USES_MITHORIUM_KERNEL),true)
ifeq ($(TARGET_KERNEL_VERSION),4.9)
BOARD_EROFS_USE_LEGACY_COMPRESSION := true
else
BOARD_EROFS_PCLUSTER_SIZE := 262144
endif # TARGET_KERNEL_VERSION
endif # TARGET_USES_MITHORIUM_KERNEL

# GRF/VF
BOARD_SHIPPING_API_LEVEL := 30

# Health
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH := /sys/class/power_supply/battery/battery_charging_enabled

# HIDL
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(COMMON_PATH)/framework_compatibility_matrix.xml
DEVICE_FRAMEWORK_MANIFEST_FILE := $(COMMON_PATH)/framework_manifest.xml
DEVICE_MANIFEST_FILE := $(COMMON_PATH)/manifest.xml
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/manifest_k$(TARGET_KERNEL_VERSION).xml
ifneq ($(TARGET_HAS_NO_CONSUMERIR),true)
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/configs/manifest/consumerir.xml
endif
ifneq ($(TARGET_HAS_NO_RADIO),true)
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/configs/manifest/radio.xml
endif
ifneq ($(TARGET_USES_DEVICE_SPECIFIC_GATEKEEPER),true)
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/configs/manifest/gatekeeper.xml
endif
ifneq ($(TARGET_USES_DEVICE_SPECIFIC_KEYMASTER),true)
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/configs/manifest/keymaster.xml
endif
ifeq ($(TARGET_USES_Q_DISPLAY_STACK),true)
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/configs/manifest/q-display-stack.xml
endif
DEVICE_MATRIX_FILE := $(COMMON_PATH)/compatibility_matrix.xml

# Init
TARGET_INIT_VENDOR_LIB ?= //$(COMMON_PATH):init_xiaomi_mithorium
TARGET_RECOVERY_DEVICE_MODULES ?= init_xiaomi_mithorium

# Partitions
TARGET_COPY_OUT_VENDOR := vendor
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_ROOT_EXTRA_SYMLINKS := \
    /vendor/dsp:/dsp \
    /vendor/firmware_mnt:/firmware \
    /mnt/vendor/persist:/persist

# Power
TARGET_USES_INTERACTION_BOOST := true

# Platform
BOARD_USES_QCOM_HARDWARE := true
ifneq ($(USE_MITHORIUM_QCOM_HALS),true)
TARGET_ENFORCES_QSSI := true
endif

# Properties
TARGET_ODM_PROP += $(COMMON_PATH)/odm.prop
TARGET_SYSTEM_PROP += $(COMMON_PATH)/system.prop
TARGET_SYSTEM_EXT_PROP += $(COMMON_PATH)/system_ext.prop
TARGET_VENDOR_PROP += $(COMMON_PATH)/vendor.prop

ifeq ($(TARGET_KERNEL_VERSION),4.19)
TARGET_VENDOR_PROP += $(COMMON_PATH)/vendor_k4.19.prop
endif

ifneq ($(TARGET_HAS_NO_RADIO),true)
TARGET_SYSTEM_PROP += $(COMMON_PATH)/system_radio.prop
TARGET_VENDOR_PROP += $(COMMON_PATH)/vendor_radio.prop
endif

# Recovery
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true

# RIL
ENABLE_VENDOR_RIL_SERVICE := true

# SELinux
include device/lineage/sepolicy/common/sepolicy.mk
include device/qcom/sepolicy-legacy-um/SEPolicy.mk
BOARD_VENDOR_SEPOLICY_DIRS += $(COMMON_PATH)/sepolicy/vendor
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(COMMON_PATH)/sepolicy/public
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(COMMON_PATH)/sepolicy/private
ifeq (true,$(call math_lt,$(PRODUCT_SHIPPING_API_LEVEL),28))
BOARD_VENDOR_SEPOLICY_DIRS += $(COMMON_PATH)/sepolicy/legacy/vendor
endif

# Treble
PRODUCT_FULL_TREBLE_OVERRIDE := true
BOARD_VNDK_VERSION := current

# Wi-Fi
BOARD_HAS_QCOM_WLAN := true
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_qcwcn
BOARD_WLAN_DEVICE := qcwcn
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_qcwcn
PRODUCT_VENDOR_MOVE_ENABLED := true
TARGET_HAS_BROKEN_WLAN_SET_INTERFACE := true
WIFI_DRIVER_FW_PATH_AP := "ap"
WIFI_DRIVER_FW_PATH_STA := "sta"
WIFI_AVOID_IFACE_RESET_MAC_CHANGE := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

# Inherit MiThorium AOSP stuff
include hardware/mithorium/aosp/BoardConfig.mk

# Inherit from the proprietary version
ifeq ($(TARGET_KERNEL_VERSION),4.9)
include vendor/xiaomi/mithorium-common/BoardConfigVendor.mk
else ifeq ($(TARGET_KERNEL_VERSION),4.19)
include vendor/xiaomi/mithorium-common-4.19/BoardConfigVendor.mk
endif

# Inherit extra if exists
-include vendor/extra/BoardConfigExtra.mk
