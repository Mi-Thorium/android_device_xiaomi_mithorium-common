/*
 * Copyright (C) 2021-2022 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <string>

typedef struct variant_info {
    std::string hwc_value;
    std::string sku_value;

    std::string brand;
    std::string device;
    std::string marketname;
    std::string model;
    std::string build_fingerprint;

    unsigned int dpi;
} variant_info_t;

void set_variant_props(const variant_info_t variant);
