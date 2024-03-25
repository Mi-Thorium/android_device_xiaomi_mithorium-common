/*
 * Copyright (C) 2018 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.1 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.1
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "RadioConfigWrapper"

#include <log/log.h>

#include "RadioConfig.h"

namespace android {
namespace hardware {
namespace radio {
namespace config {
namespace V1_1 {
namespace implementation {

using namespace ::android::hardware::radio::config::V1_1;

using android::hardware::radio::V1_0::RadioError;
using android::hardware::radio::V1_0::RadioResponseInfo;
using android::hardware::radio::V1_0::RadioResponseType;

RadioConfig::RadioConfig(sp<IRadio> radioSlot1, sp<IRadio> radioSlot2, sp<IRadioOldcfg> radioOldcfg,
                         sp<mithorm::hardware::radio::oldcfg::V1_1::IRadioOldcfg> radioOldcfgV1_1)
    : mRadioSlot1(radioSlot1),
      mRadioSlot2(radioSlot2),
      mRadioOldcfg(radioOldcfg),
      mRadioOldcfgV1_1(radioOldcfgV1_1) {
    mRadioConfigIndication = nullptr;
    mRadioConfigResponse = nullptr;
    mRadioConfigResponseV1_1 = nullptr;
}

// Methods from ::android::hardware::radio::config::V1_0::IRadioConfig follow.
Return<void> RadioConfig::setResponseFunctions(
        const sp<IRadioConfigResponse>& radioConfigResponse,
        const sp<IRadioConfigIndication>& radioConfigIndication) {
    std::lock_guard<std::mutex> lock(mMutex);
    mRadioConfigResponse = radioConfigResponse;
    mRadioConfigIndication = radioConfigIndication;
    mRadioConfigResponseV1_1 =
            ::android::hardware::radio::config::V1_1::IRadioConfigResponse::castFrom(
                    mRadioConfigResponse)
                    .withDefault(nullptr);
    return mRadioOldcfg->setResponseFunctions(
            reinterpret_cast<
                    const sp<::mithorm::hardware::radio::oldcfg::V1_0::IRadioOldcfgResponse>&>(
                    mRadioConfigResponse),
            reinterpret_cast<
                    const sp<::mithorm::hardware::radio::oldcfg::V1_0::IRadioOldcfgIndication>&>(
                    mRadioConfigIndication));
}

Return<void> RadioConfig::getSimSlotsStatus(int32_t serial) {
    return mRadioOldcfg->getSimSlotsStatus(serial);
}

Return<void> RadioConfig::setSimSlotsMapping(int32_t serial, const hidl_vec<uint32_t>& slotMap) {
    return mRadioOldcfg->setSimSlotsMapping(serial, slotMap);
}

// Methods from ::android::hardware::radio::config::V1_1::IRadioConfig follow.
Return<void> RadioConfig::getPhoneCapability(int32_t serial) {
    if (mRadioOldcfgV1_1 != nullptr) {
        return mRadioOldcfgV1_1->getPhoneCapability(serial);
    }
    RLOGI("getPhoneCapability: serial=%d", serial);
    if (mRadioConfigResponseV1_1 == nullptr) {
        RLOGE("mRadioConfigResponseV1_1 is null");
        return Void();
    }
    RadioResponseInfo responseInfo = {RadioResponseType::SOLICITED, serial, RadioError::NONE};
    /*
     * Simulates android.hardware.radio.config@1.0 behavior
     * Refer to convertHalPhoneCapability() on RILUtils.java
     */
    PhoneCapability phoneCapability = {
            .maxActiveData = 0,
            .maxActiveInternetData = 0,
            .isInternetLingeringSupported = 0,
            .logicalModemList = {},
    };
    mRadioConfigResponseV1_1->getPhoneCapabilityResponse(responseInfo, phoneCapability);
    return Void();
}

Return<void> RadioConfig::setPreferredDataModem(int32_t serial, uint8_t modemId) {
    if (mRadioOldcfgV1_1 != nullptr) {
        return mRadioOldcfgV1_1->setPreferredDataModem(serial, modemId);
    }
    std::lock_guard<std::mutex> lock(mMutex);
    RLOGI("setPreferredDataModem: serial=%d modemId=%u", serial, modemId);
    RadioError error = RadioError::NONE;
    switch (modemId) {
        case 0:                                      // slot1
            mRadioSlot2->setDataAllowed(-1, false);  // Disallow data on slot2
            mRadioSlot1->setDataAllowed(-1, true);   // Allow data on slot1
            break;
        case 1:                                      // slot2
            mRadioSlot1->setDataAllowed(-1, false);  // Disallow data on slot1
            mRadioSlot2->setDataAllowed(-1, true);   // Allow data on slot2
            break;
        default:
            error = RadioError::INTERNAL_ERR;
            break;
    }
    if (mRadioConfigResponseV1_1 == nullptr) {
        RLOGE("mRadioConfigResponseV1_1 is null");
        return Void();
    }
    RadioResponseInfo responseInfo = {RadioResponseType::SOLICITED, serial, error};
    mRadioConfigResponseV1_1->setPreferredDataModemResponse(responseInfo);
    return Void();
}

Return<void> RadioConfig::setModemsConfig(int32_t serial, const ModemsConfig& modemsConfig) {
    if (mRadioOldcfgV1_1 != nullptr) {
        return mRadioOldcfgV1_1->setModemsConfig(
                serial,
                reinterpret_cast<const ::mithorm::hardware::radio::oldcfg::V1_1::ModemsConfig&>(
                        modemsConfig));
    }
    RLOGI("setModemsConfig: serial=%d modemsConfig.numOfLiveModems=%d", serial,
          modemsConfig.numOfLiveModems);
    if (mRadioConfigResponseV1_1 == nullptr) {
        RLOGE("mRadioConfigResponseV1_1 is null");
        return Void();
    }
    RadioResponseInfo responseInfo = {RadioResponseType::SOLICITED, serial,
                                      RadioError::REQUEST_NOT_SUPPORTED};
    mRadioConfigResponseV1_1->setModemsConfigResponse(responseInfo);
    return Void();
}

Return<void> RadioConfig::getModemsConfig(int32_t serial) {
    if (mRadioOldcfgV1_1 != nullptr) {
        return mRadioOldcfgV1_1->getModemsConfig(serial);
    }
    RLOGI("getModemsConfig: serial=%d", serial);
    if (mRadioConfigResponseV1_1 == nullptr) {
        RLOGE("mRadioConfigResponseV1_1 is null");
        return Void();
    }
    RadioResponseInfo responseInfo = {RadioResponseType::SOLICITED, serial,
                                      RadioError::REQUEST_NOT_SUPPORTED};
    ModemsConfig modemsConfig = {};
    mRadioConfigResponseV1_1->getModemsConfigResponse(responseInfo, modemsConfig);
    return Void();
}

}  // namespace implementation
}  // namespace V1_1
}  // namespace config
}  // namespace radio
}  // namespace hardware
}  // namespace android
