/*
 * Copyright (C) 2021 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <android-base/properties.h>
#include <dlfcn.h>
#include <log/log.h>
#include "DumpstateUtil.h"

#include "Dumpstate.h"

#define DEVICE_HANDLER_LIB_NAME "libdumpstate_device.so"
#define DEVICE_HANDLER_LIB_SYMBOL "dumpstate_device_handler"

using android::os::dumpstate::CommandOptions;
using android::os::dumpstate::DumpFileToFd;
using android::base::SetProperty;

namespace aidl {
namespace android {
namespace hardware {
namespace dumpstate {

const char kVerboseLoggingProperty[] = "persist.dumpstate.verbose_logging.enabled";

ndk::ScopedAStatus Dumpstate::dumpstateBoard(const std::vector<::ndk::ScopedFileDescriptor>& in_fds,
                                             IDumpstateDevice::DumpstateMode in_mode,
                                             int64_t in_timeoutMillis) {
    (void)in_timeoutMillis;

    if (in_fds.size() < 1) {
        return ndk::ScopedAStatus::fromExceptionCodeWithMessage(EX_ILLEGAL_ARGUMENT,
                                                                "No file descriptor");
    }

    int fd = in_fds[0].get();
    if (fd < 0) {
        return ndk::ScopedAStatus::fromExceptionCodeWithMessage(EX_ILLEGAL_ARGUMENT,
                                                                "Invalid file descriptor");
    }

    switch (in_mode) {
        case IDumpstateDevice::DumpstateMode::FULL:
            return dumpstateBoardImpl(fd, true);

        case IDumpstateDevice::DumpstateMode::DEFAULT:
            return dumpstateBoardImpl(fd, false);

        case IDumpstateDevice::DumpstateMode::INTERACTIVE:
        case IDumpstateDevice::DumpstateMode::REMOTE:
        case IDumpstateDevice::DumpstateMode::WEAR:
        case IDumpstateDevice::DumpstateMode::CONNECTIVITY:
        case IDumpstateDevice::DumpstateMode::WIFI:
        case IDumpstateDevice::DumpstateMode::PROTO:
            return ndk::ScopedAStatus::fromServiceSpecificErrorWithMessage(ERROR_UNSUPPORTED_MODE,
                                                                           "Unsupported mode");

        default:
            return ndk::ScopedAStatus::fromExceptionCodeWithMessage(EX_ILLEGAL_ARGUMENT,
                                                                    "Invalid mode");
    }

    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Dumpstate::getVerboseLoggingEnabled(bool* _aidl_return) {
    *_aidl_return = getVerboseLoggingEnabledImpl();
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Dumpstate::setVerboseLoggingEnabled(bool in_enable) {
    SetProperty(kVerboseLoggingProperty, in_enable ? "true" : "false");
    return ndk::ScopedAStatus::ok();
}

bool Dumpstate::getVerboseLoggingEnabledImpl() {
    return ::android::base::GetBoolProperty(kVerboseLoggingProperty, false);
}

ndk::ScopedAStatus Dumpstate::dumpstateBoardImpl(const int fd, const bool full) {
    ALOGD("DumpstateDevice::dumpstateBoard() FD: %d\n", fd);

    dprintf(fd, "verbose logging: %s\n", getVerboseLoggingEnabledImpl() ? "enabled" : "disabled");
    dprintf(fd, "[%s] %s\n", (full ? "full" : "default"), "Hello, world!");

    // DebugFS
    DumpFileToFd(fd, "Wakeup sources", "/sys/kernel/debug/wakeup_sources");

    // eMMC
    DumpFileToFd(fd, "eMMC date", "/sys/devices/platform/soc/7824900.sdhci/mmc_host/mmc0/mmc0:0001/date");
    DumpFileToFd(fd, "eMMC lifetime", "/sys/devices/platform/soc/7824900.sdhci/mmc_host/mmc0/mmc0:0001/life_time");
    DumpFileToFd(fd, "eMMC manfid", "/sys/devices/platform/soc/7824900.sdhci/mmc_host/mmc0/mmc0:0001/manfid");
    DumpFileToFd(fd, "eMMC name", "/sys/devices/platform/soc/7824900.sdhci/mmc_host/mmc0/mmc0:0001/name");

    // Kernel log
    DumpFileToFd(fd, "Kernel log (early)", "/data/vendor/dmesg/dmesg_early.log");
    RunCommandToFd(fd, "Kernel log (current)", {"/vendor/bin/dmesg", "-T"}, CommandOptions::WithTimeout(1).Build());

    // Misc
    DumpFileToFd(fd, "Firmware version info", "/sys/devices/soc0/images");

    // MSM Framebuffer
    DumpFileToFd(fd, "Display CABC", "/sys/devices/virtual/graphics/fb0/cabc");
    DumpFileToFd(fd, "Display CE", "/sys/devices/virtual/graphics/fb0/color_enhance");
    DumpFileToFd(fd, "Display HBM", "/sys/devices/virtual/graphics/fb0/hbm");
    DumpFileToFd(fd, "Display Reading mode", "/sys/devices/virtual/graphics/fb0/reading_mode");
    DumpFileToFd(fd, "Display Panel info", "/sys/devices/virtual/graphics/fb0/msm_fb_panel_info");
    DumpFileToFd(fd, "Display Panel status", "/sys/devices/virtual/graphics/fb0/msm_fb_panel_status");

    // Power supply
    DumpFileToFd(fd, "Battery health", "/sys/class/power_supply/battery/health");
    DumpFileToFd(fd, "Battery charging enabled", "/sys/class/power_supply/battery/battery_charging_enabled");
    DumpFileToFd(fd, "Battery charging enabled 2", "/sys/class/power_supply/battery/charging_enabled");
    DumpFileToFd(fd, "Battery input suspend", "/sys/class/power_supply/battery/input_suspend");
    DumpFileToFd(fd, "Battery charge type", "/sys/class/power_supply/battery/charge_type");
    DumpFileToFd(fd, "Battery mAh", "/sys/class/power_supply/battery/charge_full");
    DumpFileToFd(fd, "Battery mAh design", "/sys/class/power_supply/battery/charge_full_design");
    DumpFileToFd(fd, "USB max current", "/sys/class/power_supply/usb/current_max");
    DumpFileToFd(fd, "USB real type", "/sys/class/power_supply/usb/real_type");
    DumpFileToFd(fd, "USB type", "/sys/class/power_supply/usb/type");

    // ProcFS
    DumpFileToFd(fd, "Interrupts", "/proc/interrupts");
    DumpFileToFd(fd, "Mount info", "/proc/self/mountinfo");

    // Restart services (To make their early logs appear again on logcat)
    SetProperty("ctl.stop", "vendor.camera-provider-2-4");
    SetProperty("ctl.stop", "vendor.qcamerasvr");
    SetProperty("ctl.start", "vendor.qcamerasvr");
    sleep(1);
    SetProperty("ctl.start", "vendor.camera-provider-2-4");
    sleep(1);
    SetProperty("ctl.stop", "vendor.fps_hal");
    SetProperty("ctl.start", "vendor.fps_hal");
    usleep(500000);

    // Open device specific library
    void* libdumpstate_device = dlopen(DEVICE_HANDLER_LIB_NAME, RTLD_LAZY);
    if (libdumpstate_device) {
        void (*dumpstate_device_handler)(const int fd, const bool full) =
            (void (*)(const int, const bool))dlsym(libdumpstate_device, DEVICE_HANDLER_LIB_SYMBOL);
        if (dumpstate_device_handler) {
            dumpstate_device_handler(fd, full);
        }
        dlclose(libdumpstate_device);
    }

    return ndk::ScopedAStatus::ok();
}

}  // namespace dumpstate
}  // namespace hardware
}  // namespace android
}  // namespace aidl
