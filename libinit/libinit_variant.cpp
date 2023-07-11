/*
 * Copyright (C) 2021-2022 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <libinit_utils.h>

#include <libinit_variant.h>

void set_variant_props(const variant_info_t variant) {
    set_ro_build_prop("brand", variant.brand, true);
    set_ro_build_prop("device", variant.device, true);
    set_ro_build_prop("marketname", variant.marketname, true);
    set_ro_build_prop("model", variant.model, true);

    if (variant.dpi)
        property_override("ro.sf.lcd_density", std::to_string(variant.dpi));

    if (!variant.build_fingerprint.empty()) {
        set_ro_build_prop("fingerprint", variant.build_fingerprint);
        property_override("ro.bootimage.build.fingerprint", variant.build_fingerprint);
        property_override("ro.build.description", fingerprint_to_description(variant.build_fingerprint));
    }
}
