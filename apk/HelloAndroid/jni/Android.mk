LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := eng

LOCAL_MODULE := libesm_model
LOCAL_SRC_FILES:= sample.cpp
LOCAL_SHARED_LIBRARIES := \
	libutils liblog libcutils libc

LOCAL_C_INCLUDES += \
	$(JNI_H_INCLUDE)

LOCAL_CFLAGS += -O0 -g

include $(BUILD_SHARED_LIBRARY)
