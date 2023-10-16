/*
 * Copyright (C) 2021 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "Dumpstate.h"

#include <android-base/logging.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>
#include <fcntl.h>

using aidl::android::hardware::dumpstate::Dumpstate;

int main(int argc, char *argv[]) {
    std::shared_ptr<Dumpstate> dumpstate = ndk::SharedRefBase::make<Dumpstate>();

    if (argc == 2 && (std::string(argv[1]) == "--service")) {
        ABinderProcess_setThreadPoolMaxThreadCount(0);

        const std::string instance = std::string() + Dumpstate::descriptor + "/default";
        binder_status_t status =
                AServiceManager_registerLazyService(dumpstate->asBinder().get(), instance.c_str());
        CHECK_EQ(status, STATUS_OK);

        ABinderProcess_joinThreadPool();
        return EXIT_FAILURE;  // Unreachable
    } else {
        int fd = open("/dev/stdout", O_WRONLY);
        if (fd < 0)
            return 1;
        dumpstate->dumpstateBoardImpl(fd, true);
        close(fd);
    }

    return 0;
}
