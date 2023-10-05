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

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_TARGET=
KERNEL_4_19=
KANG=
SECTION=

SETUP_MAKEFILES_ARGS=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                SETUP_MAKEFILES_ARGS+=" ${1}"
                ;;
        --only-target )
                ONLY_TARGET=true
                SETUP_MAKEFILES_ARGS+=" ${1}"
                ;;
        --kernel-4.19 )
                KERNEL_4_19=true
                SETUP_MAKEFILES_ARGS+=" ${1}"
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

if [ -z "${DEVICE_PARENT}" ]; then
    DEVICE_PARENT="."
fi

if [ "${KERNEL_4_19}" == "true" ]; then
    DEVICE_COMMON="mithorium-common-4.19"
fi

function blob_fixup() {
    case "${1}" in
        product/etc/permissions/vendor.qti.hardware.data.connection-V1.0-java.xml \
        | product/etc/permissions/vendor.qti.hardware.data.connection-V1.1-java.xml)
            sed -i 's|version="2.0"|version="1.0"|g' "${2}"
            ;;
        system_ext/lib64/lib-imscamera.so)
            for LIBSHIM_IMSVIDEOCODEC in $(grep -L "libshim_imscamera.so" "${2}"); do
                "${PATCHELF}" --add-needed "libshim_imscamera.so" "${2}"
            done
            ;;
        vendor/lib64/libwvhidl.so|vendor/lib64/mediadrm/libwvdrmengine.so)
            sed -i 's|libprotobuf-cpp-lite-3.9.1.so|libprotobuf-cpp-full-3.9.1.so|g' "${2}"
            ;;
    esac
}

if [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

    if [ "${KERNEL_4_19}" != "true" ]; then
        # Kernel 4.9
        extract "${MY_DIR}/proprietary-files/4.9/qcom-system.txt" "${SRC}" "${KANG}" --section "${SECTION}"
        extract "${MY_DIR}/proprietary-files/4.9/qcom-vendor.txt" "${SRC}" "${KANG}" --section "${SECTION}"
        extract "${MY_DIR}/proprietary-files/4.9/qcom-vendor-32.txt" "${SRC}" "${KANG}" --section "${SECTION}"
        extract "${MY_DIR}/proprietary-files/4.9/qcom-vendor-multilib-module.txt" "${SRC}" "${KANG}" --section "${SECTION}"

        extract "${MY_DIR}/proprietary-files/4.9/qcom-system-radio.txt" "${SRC}" "${KANG}" --section "${SECTION}"
        extract "${MY_DIR}/proprietary-files/4.9/qcom-vendor-radio.txt" "${SRC}" "${KANG}" --section "${SECTION}"
    else
        # Kernel 4.19
        extract "${MY_DIR}/proprietary-files/4.19/qcom-system.txt" "${SRC}" "${KANG}" --section "${SECTION}"
        extract "${MY_DIR}/proprietary-files/4.19/qcom-vendor.txt" "${SRC}" "${KANG}" --section "${SECTION}"
        extract "${MY_DIR}/proprietary-files/4.19/qcom-vendor-32.txt" "${SRC}" "${KANG}" --section "${SECTION}"
        extract "${MY_DIR}/proprietary-files/4.19/qcom-vendor-multilib-module.txt" "${SRC}" "${KANG}" --section "${SECTION}"

        extract "${MY_DIR}/proprietary-files/4.19/qcom-system-radio.txt" "${SRC}" "${KANG}" --section "${SECTION}"
        extract "${MY_DIR}/proprietary-files/4.19/qcom-vendor-radio.txt" "${SRC}" "${KANG}" --section "${SECTION}"
    fi
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../${DEVICE_PARENT}/${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../${DEVICE_PARENT}/${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    for proprietary_files_txt in ${MY_DIR}/../${DEVICE_PARENT}/${DEVICE}/proprietary-files*.txt; do
        extract "$proprietary_files_txt" "${SRC}" "${KANG}" --section "${SECTION}"
    done
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../${DEVICE_SPECIFIED_COMMON}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device specified common
    source "${MY_DIR}/../${DEVICE_SPECIFIED_COMMON}/extract-files.sh"
    setup_vendor "${DEVICE_SPECIFIED_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    for proprietary_files_txt in ${MY_DIR}/../${DEVICE_SPECIFIED_COMMON}/proprietary-files*.txt; do
        extract "$proprietary_files_txt" "${SRC}" "${KANG}" --section "${SECTION}"
    done
fi

"${MY_DIR}/setup-makefiles.sh" ${SETUP_MAKEFILES_ARGS}
