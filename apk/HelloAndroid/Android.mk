LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := eng

LOCAL_SRC_FILES := \
        $(call all-java-files-under, src) \
        $(call all-proto-files-under, src)

LOCAL_PACKAGE_NAME := HelloAndroid
LOCAL_CERTIFICATE := platform
LOCAL_PRIVILEGED_MODULE := true
LOCAL_USE_AAPT2 := true

LOCAL_JNI_SHARED_LIBRARIES := libesm_model
LOCAL_JAVA_LIBRARIES :=
LOCAL_STATIC_JAVA_LIBRARIES :=
LOCAL_STATIC_ANDROID_LIBRARIES := \
        android-support-v4
LOCAL_PROTOC_OPTIMIZE_TYPE := micro

LOCAL_REQUIRED_MODULES :=

LOCAL_PROGUARD_ENABLED := disabled

include $(PREBUILT_SHARED_LIBRARY)
include $(BUILD_PACKAGE)

include $(call all-makefiles-under,$(LOCAL_PATH))
