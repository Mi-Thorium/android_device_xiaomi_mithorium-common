#!/vendor/bin/sh

ACDB_BIN_PATH="/vendor/etc/acdbdata"
ETC_ROOT_PATH="/vendor/etc"
DEFAULT_BOARD="MTP"
LOG_TAG="init.acdbdata.sh"
CALFILE_PROP="persist.vendor.audio.calfile"

LOGE() {
    log -p f "${LOG_TAG}: ACDB -> $@"
    echo "E ${LOG_TAG}: ACDB -> $@"
}

LOGI() {
    log -p i "${LOG_TAG}: ACDB -> $@"
    echo "I ${LOG_TAG}: ACDB -> $@"
}

COMPATIBLE="$(cat /sys/firmware/devicetree/base/compatible)"
if [ -z "$COMPATIBLE" ]; then
    LOGE "Unable to read dts compatible"
    exit 1
fi

is_compatible() {
    if echo -n "$COMPATIBLE" | grep "$1" 2>&1 > /dev/null ; then
        return 0
    else
        return 1
    fi
}

if is_compatible "qcom,mtp"; then
    BOARD_TYPE="MTP"
elif is_compatible "qcom,qrd"; then
    BOARD_TYPE="QRD"
else
    LOGE "Unable to determine board type"
    exit 1
fi

LOGI "board_type = $BOARD_TYPE"

get_acdb_files() {
    dir="$1"
    if ! [ -d "$dir" ]; then LOGE "Failed to open directory ${dir}" ; return 1; fi
    files="`find $dir -type f \( -name '*.acdb' -o -name '*.qwsp' \) -maxdepth 1`"
    if [ -z "$files" ]; then LOGE "Failed to list files in directory ${dir}" ; return 1 ; fi
    i=0
    for f in $files; do
        setprop ${CALFILE_PROP}${i} ${f} || LOGE "setprop failed for prop: ${CALFILE_PROP}${i}=${f}"
        LOGI "Set calfile ${i}: ${f}"
        let i+=1
    done
    exit 0
}

SND_CARD_NAME="$(cat /sys/firmware/devicetree/base/soc/sound/qcom,model)"
if [ "$SND_CARD_NAME" ]; then
    get_acdb_files "${ACDB_BIN_PATH}/${BOARD_TYPE}/${SND_CARD_NAME}"
fi

get_acdb_files "${ACDB_BIN_PATH}/${BOARD_TYPE}"

if [ "$SND_CARD_NAME" ] && [ "$DEFAULT_BOARD" != "$BOARD_TYPE" ]; then
    get_acdb_files "${ACDB_BIN_PATH}/${DEFAULT_BOARD}/${SND_CARD_NAME}"
fi

get_acdb_files "${ACDB_BIN_PATH}/${DEFAULT_BOARD}"

get_acdb_files "${ETC_ROOT_PATH}"

LOGE "Could not open any directory!"
exit 1