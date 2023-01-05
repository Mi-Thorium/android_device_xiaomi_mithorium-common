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
    esac
    shift
done

if [ -z "$ONLY_TARGET" ]; then
    # Initialize the helper for common
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true

    # Warning headers and guards
    write_headers "Mi8937 Mi439"

    # The standard common blobs
    write_makefiles "${MY_DIR}/proprietary-files-qc-sys.txt" true
    write_makefiles "${MY_DIR}/proprietary-files-qc-vndr.txt" true
    write_makefiles "${MY_DIR}/proprietary-files-qc-vndr-32.txt" true

    # Finish
    write_footers
fi

if [ -z "$ONLY_COMMON" ]; then
    if [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
        # Reinitialize the helper for device
        setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false

        # Warning headers and guards
        write_headers

        # The standard device blobs
        write_makefiles "${MY_DIR}/../${DEVICE}/proprietary-files.txt" true

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
        write_makefiles "${MY_DIR}/../${DEVICE_SPECIFIED_COMMON}/proprietary-files.txt" true

        # Finish
        write_footers
    fi
fi
