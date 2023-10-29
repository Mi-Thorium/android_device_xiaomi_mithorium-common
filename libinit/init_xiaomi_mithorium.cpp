/*
 * Copyright (C) 2021-2022 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <libinit_dalvik_heap.h>
#include <libinit_utils.h>

#include "vendor_init.h"

void vendor_load_properties() {
    set_dalvik_heap();

    property_override("ro.secure", "0");
    property_override("ro.adb.secure", "0");
    property_override("ro.debuggable", "1");
    property_override("sys.usb.config", "adb");
    property_override("persist.sys.usb.config", "adb");
}
