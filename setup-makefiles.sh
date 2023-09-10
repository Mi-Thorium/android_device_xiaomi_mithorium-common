#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                ;;
        --only-target )
                ONLY_TARGET=true
                ;;
        --kernel-4.19 )
                KERNEL_4_19=true
                SETUP_MAKEFILES_ARGS+=" ${1}"
                ;;
    esac
    shift
done

if [ -z "${DEVICE_PARENT}" ]; then
    DEVICE_PARENT="."
fi

if [ "${KERNEL_4_19}" == "true" ]; then
    DEVICE_COMMON="mithorium-common-4.19"
fi

if [ -z "$ONLY_TARGET" ]; then
    # Initialize the helper for common
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true

    # Warning headers and guards
    write_headers "MiThoriumSSI Mi8937 Mi439_4_19 Tiare oxygen uter vince onc"

    # The standard common blobs
    if [ "${KERNEL_4_19}" != "true" ]; then
        # Kernel 4.9
        write_makefiles "${MY_DIR}/proprietary-files/4.9/qcom-system.txt" true
        write_makefiles "${MY_DIR}/proprietary-files/4.9/qcom-vendor.txt" true
        write_makefiles "${MY_DIR}/proprietary-files/4.9/qcom-vendor-32.txt" true
        write_makefiles "${MY_DIR}/proprietary-files/4.9/qcom-vendor-multilib-module.txt" true
    else
        # Kernel 4.19
        write_makefiles "${MY_DIR}/proprietary-files/4.19/qcom-system.txt" true
        write_makefiles "${MY_DIR}/proprietary-files/4.19/qcom-vendor.txt" true
        write_makefiles "${MY_DIR}/proprietary-files/4.19/qcom-vendor-32.txt" true
        write_makefiles "${MY_DIR}/proprietary-files/4.19/qcom-vendor-multilib-module.txt" true
    fi

    # Finish
    write_footers
fi

if [ -z "$ONLY_COMMON" ]; then
    if [ -s "${MY_DIR}/../${DEVICE_PARENT}/${DEVICE}/proprietary-files.txt" ]; then
        # Reinitialize the helper for device
        setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false

        # Warning headers and guards
        write_headers

        # The standard device blobs
        for proprietary_files_txt in ${MY_DIR}/../${DEVICE_PARENT}/${DEVICE}/proprietary-files*.txt; do
            write_makefiles "$proprietary_files_txt" true
        done

        # Finish
        write_footers
    fi

    if [ -s "${MY_DIR}/../${DEVICE_SPECIFIED_COMMON}/proprietary-files.txt" ]; then
        # Workaround: Define $DEVICE
        export DEVICE="${DEVICE_SPECIFIED_COMMON}"
        export DEVICE_COMMON="${DEVICE_SPECIFIED_COMMON}"

        # Reinitialize the helper for device specified common
        setup_vendor "${DEVICE_SPECIFIED_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true

        # Warning headers and guards
        write_headers "$DEVICE_SPECIFIED_COMMON_DEVICE"

        # The standard device blobs
        for proprietary_files_txt in ${MY_DIR}/../${DEVICE_SPECIFIED_COMMON}/proprietary-files*.txt; do
            write_makefiles "$proprietary_files_txt" true
        done

        # Finish
        write_footers
    fi
fi
