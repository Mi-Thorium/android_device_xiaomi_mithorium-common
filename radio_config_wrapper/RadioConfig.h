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

#pragma once

#include <android/hardware/radio/1.0/IRadio.h>
#include <android/hardware/radio/config/1.1/IRadioConfig.h>
#include <android/hardware/radio/config/1.1/IRadioConfigIndication.h>
#include <android/hardware/radio/config/1.1/IRadioConfigResponse.h>
#include <hidl/MQDescriptor.h>
#include <hidl/Status.h>
#include <mithorm/hardware/radio/oldcfg/1.1/IRadioOldcfg.h>
#include <mithorm/hardware/radio/oldcfg/1.1/IRadioOldcfgIndication.h>
#include <mithorm/hardware/radio/oldcfg/1.1/IRadioOldcfgResponse.h>

namespace android {
namespace hardware {
namespace radio {
namespace config {
namespace V1_1 {
namespace implementation {

using ::android::sp;
using ::android::hardware::hidl_array;
using ::android::hardware::hidl_memory;
using ::android::hardware::hidl_string;
using ::android::hardware::hidl_vec;
using ::android::hardware::Return;
using ::android::hardware::Void;

using android::hardware::radio::config::V1_0::IRadioConfigIndication;
using android::hardware::radio::config::V1_0::IRadioConfigResponse;
using android::hardware::radio::V1_0::IRadio;
using mithorm::hardware::radio::oldcfg::V1_0::IRadioOldcfg;

class RadioConfig : public IRadioConfig {
  public:
    RadioConfig(sp<IRadio> radioSlot1, sp<IRadio> radioSlot2, sp<IRadioOldcfg> radioOldcfg,
                sp<mithorm::hardware::radio::oldcfg::V1_1::IRadioOldcfg> radioOldcfgV1_1);
    // Methods from ::android::hardware::radio::config::V1_0::IRadioConfig follow.
    Return<void> setResponseFunctions(
            const sp<::android::hardware::radio::config::V1_0::IRadioConfigResponse>&
                    radioConfigResponse,
            const sp<::android::hardware::radio::config::V1_0::IRadioConfigIndication>&
                    radioConfigIndication) override;
    Return<void> getSimSlotsStatus(int32_t serial) override;
    Return<void> setSimSlotsMapping(int32_t serial, const hidl_vec<uint32_t>& slotMap) override;

    // Methods from ::android::hardware::radio::config::V1_1::IRadioConfig follow.
    Return<void> getPhoneCapability(int32_t serial) override;
    Return<void> setPreferredDataModem(int32_t serial, uint8_t modemId) override;
    Return<void> setModemsConfig(
            int32_t serial,
            const ::android::hardware::radio::config::V1_1::ModemsConfig& modemsConfig) override;
    Return<void> getModemsConfig(int32_t serial) override;

  private:
    sp<IRadio> mRadioSlot1;
    sp<IRadio> mRadioSlot2;
    sp<IRadioOldcfg> mRadioOldcfg;
    sp<mithorm::hardware::radio::oldcfg::V1_1::IRadioOldcfg> mRadioOldcfgV1_1;
    sp<IRadioConfigIndication> mRadioConfigIndication;
    sp<IRadioConfigResponse> mRadioConfigResponse;
    sp<::android::hardware::radio::config::V1_1::IRadioConfigResponse> mRadioConfigResponseV1_1;
    std::mutex mMutex;
};

}  // namespace implementation
}  // namespace V1_1
}  // namespace config
}  // namespace radio
}  // namespace hardware
}  // namespace android
