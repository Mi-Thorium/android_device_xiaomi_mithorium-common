/*
 * Copyright (C) 2021 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <string>

void property_override(std::string prop, std::string value, bool add = true);

void set_ro_build_prop(const std::string &prop, const std::string &value, bool product = false);

std::string fingerprint_to_description(std::string fingerprint);
