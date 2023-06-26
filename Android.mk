#
# Copyright (C) 2017-2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_USES_XIAOMI_MITHORIUM_COMMON_TREE),true)

include $(call all-makefiles-under,$(LOCAL_PATH))

include $(CLEAR_VARS)

#A/B builds require us to create the mount points at compile time.
#Just creating it for all cases since it does not hurt.
FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/firmware_mnt
DSP_MOUNT_POINT := $(TARGET_OUT_VENDOR)/dsp
ALL_DEFAULT_INSTALLED_MODULES += $(FIRMWARE_MOUNT_POINT) \
				 $(DSP_MOUNT_POINT)
$(FIRMWARE_MOUNT_POINT):
	@echo "Creating $(FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware_mnt

$(DSP_MOUNT_POINT):
	@echo "Creating $(DSP_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/dsp

IMS_LIBS := libimscamera_jni.so libimsmedia_jni.so

IMS_SYMLINKS := $(addprefix $(TARGET_OUT_SYSTEM_EXT_APPS_PRIVILEGED)/ims/lib/arm64/,$(notdir $(IMS_LIBS)))
$(IMS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "IMS lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /system_ext/lib64/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(IMS_SYMLINKS)

RFS_MSM_ADSP_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/msm/adsp/
$(RFS_MSM_ADSP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM ADSP folder structure: $@"
	@rm -rf $@/*
	@mkdir -p $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/lpass $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/adsp $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

RFS_MSM_MPSS_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/msm/mpss/
$(RFS_MSM_MPSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM MPSS folder structure: $@"
	@rm -rf $@/*
	@mkdir -p $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/modem $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/mpss $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

RFS_MSM_SLPI_SYMLINKS := $(TARGET_OUT_VENDOR)/rfs/msm/slpi/
$(RFS_MSM_SLPI_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM SLPI folder structure: $@"
	@rm -rf $@/*
	@mkdir -p $(dir $@)/readonly/vendor
	$(hide) ln -sf /data/vendor/tombstones/rfs/slpi $@/ramdumps
	$(hide) ln -sf /mnt/vendor/persist/rfs/msm/slpi $@/readwrite
	$(hide) ln -sf /mnt/vendor/persist/rfs/shared $@/shared
	$(hide) ln -sf /mnt/vendor/persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /vendor/firmware_mnt $@/readonly/firmware
	$(hide) ln -sf /vendor/firmware $@/readonly/vendor/firmware

ALL_DEFAULT_INSTALLED_MODULES += $(RFS_MSM_ADSP_SYMLINKS) $(RFS_MSM_MPSS_SYMLINKS) $(RFS_MSM_SLPI_SYMLINKS)

WCNSS_INI_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/prima/WCNSS_qcom_cfg.ini
$(WCNSS_INI_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS config ini link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /vendor/etc/wifi/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(WCNSS_INI_SYMLINK)

EGL_32_SYMLINK := $(TARGET_OUT_VENDOR)/lib/libEGL_adreno.so
$(EGL_32_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 32-bit EGL symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

GLESv2_32_SYMLINK := $(TARGET_OUT_VENDOR)/lib/libGLESv2_adreno.so
$(GLESv2_32_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 32-bit GLESv2 symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

Q3DTOOLS_32_SYMLINK := $(TARGET_OUT_VENDOR)/lib/libq3dtools_adreno.so
$(Q3DTOOLS_32_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 32-bit Q3D Tools symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

EGL_64_SYMLINK := $(TARGET_OUT_VENDOR)/lib64/libEGL_adreno.so
$(EGL_64_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 64-bit EGL symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

GLESv2_64_SYMLINK := $(TARGET_OUT_VENDOR)/lib64/libGLESv2_adreno.so
$(GLESv2_64_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 64-bit GLESv2 symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

Q3DTOOLS_64_SYMLINK := $(TARGET_OUT_VENDOR)/lib64/libq3dtools_adreno.so
$(Q3DTOOLS_64_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating 64-bit Q3DTools symlink: $@"
	@mkdir -p $(dir $@)
	$(hide) ln -sf egl/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(EGL_32_SYMLINK) $(GLESv2_32_SYMLINK) $(Q3DTOOLS_32_SYMLINK) $(EGL_64_SYMLINK) $(GLESv2_64_SYMLINK) $(Q3DTOOLS_64_SYMLINK)

ifeq ($(filter Motorola motorola,$(TARGET_VENDOR)),)
ifeq ($(filter oxygen,$(TARGET_DEVICE)),)
WCNSS_BIN_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/prima/WCNSS_qcom_wlan_nv.bin
$(WCNSS_BIN_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS bin link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /mnt/vendor/persist/$(notdir $@) $@

WCNSS_DAT_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/prima/WCNSS_wlan_dictionary.dat
$(WCNSS_DAT_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS dat link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /mnt/vendor/persist/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(WCNSS_BIN_SYMLINK) $(WCNSS_DAT_SYMLINK)
endif
endif

ifeq ($(filter Mi439 Mi439_4_19,$(TARGET_DEVICE)),)
WCNSS_MAC_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/prima/wlan_mac.bin
$(WCNSS_MAC_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS MAC bin link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /mnt/vendor/persist/$(notdir $@) $@
ALL_DEFAULT_INSTALLED_MODULES += $(WCNSS_MAC_SYMLINK)
endif

CNE_LIBS := libvndfwk_detect_jni.qti.so
CNE_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/app/CneApp/lib/arm64/,$(notdir $(CNE_LIBS)))
$(CNE_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "CneApp lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /vendor/lib64/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(CNE_SYMLINKS)

ifeq ($(TARGET_BOARD_PLATFORM),msm8953)
ST_LIBS := sound_trigger.primary.msm8953.so
ST_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/lib/hw/,$(notdir $(ST_LIBS)))
$(ST_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "sound_trigger lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /vendor/lib/hw/sound_trigger.primary.msm8937.so $@

ALL_DEFAULT_INSTALLED_MODULES += $(ST_SYMLINKS)
endif

include $(CLEAR_VARS)
LOCAL_MODULE := mithorium_product_packages
LOCAL_MODULE_CLASS := FAKE
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_PATH := $(TARGET_OUT_FAKE)
LOCAL_REQUIRED_MODULES := $(MITHORIUM_PRODUCT_PACKAGES)
include $(BUILD_PHONY_PACKAGE)

endif
