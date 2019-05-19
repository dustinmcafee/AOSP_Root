#include <utils/Log.h>
#include <stdio.h>
#include <cutils/properties.h>
#include <unistd.h>
#include <sys/types.h>
#include <linux/input-event-codes.h>	//for EV_* and BTN_* macros
#include <sys/syscall.h>		//for SYS_esm_register and SYS_esm_wait

#include "jni.h"

// Android log function wrappers
static const char* kTAG = "JNI ESM (HelloAndroid) SAMPLE";
#define LOGI(...) \
  ((void)__android_log_print(ANDROID_LOG_INFO, kTAG, __VA_ARGS__))
#define LOGW(...) \
  ((void)__android_log_print(ANDROID_LOG_WARN, kTAG, __VA_ARGS__))
#define LOGE(...) \
((void)__android_log_print(ANDROID_LOG_ERROR, kTAG, __VA_ARGS__))

struct input_value {
    __u16 type;
    __u16 code;
    unsigned int value;
};

const struct input_value input_struct = {
//    .type = EV_KEY,
//    .code = BTN_LEFT
    .type = 3,			//For Emulator-goldfish
    .code = 57			//For Emulator-goldfish
};

//#define SYS_esm_register 332
//#define SYS_esm_wait 333

namespace com_example_helloandroid {

	int pid;

    void click_handler(__u16 type, __u16 code, int value){
        printf("We did it!\n%d\n",value);
        LOGI("We did it!\n");
        int err = syscall(SYS_esm_register, pid, input_struct.type, input_struct.code, NULL);
//        int err = esm_register(pid, input_struct.type, input_struct.code, NULL);
        if(err == -1){printf("error with unregistering handler with esm\n"); LOGE("error with unregistering handler with esm\n");}
    }


    static jint my_esm_register(JNIEnv *env, jclass clazz) {
        pid = getpid();
        int err = syscall(SYS_esm_register, pid, input_struct.type, input_struct.code, click_handler);
//        int err = esm_register(pid, input_struct.type, input_struct.code, &click_handler);
        if(err == -1){printf("error with esm register\n"); LOGE("error with esm register\n");}

        return err;
    }

    static jint my_esm_wait(JNIEnv *env, jclass clazz) {
        pid = getpid();
        printf("esm wait call on pid %d\n", pid); LOGI("esm wait call on pid\n");
        int err = syscall(SYS_esm_wait, pid);
//        int err = esm_wait(pid);
        if(err == -1){printf("error with esm wait\n"); LOGE("error with esm wait\n");}

        return err;
    }


    static JNINativeMethod method_table[] = {
            { "my_ESM_register", "()I", (void *) my_esm_register },
            { "my_ESM_wait", "()I", (void *) my_esm_wait }
    };
}

using namespace com_example_helloandroid;

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
printf("SYS_esm_Register: %d; __NR_esm_register: %d\n",SYS_esm_register, __NR_esm_register);
printf("SYS_esm_wait: %d; __NR_esm_wait: %d\n",SYS_esm_wait, __NR_esm_wait);
LOGI("SYS_esm_Register: %d; __NR_esm_register: %d\n",SYS_esm_register, __NR_esm_register);
LOGI("SYS_esm_wait: %d; __NR_esm_wait: %d\n",SYS_esm_wait, __NR_esm_wait);

    JNIEnv* env;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    } else {
        jclass clazz = env->FindClass("com/example/helloandroid/MainActivity");
        if (clazz) {
            jint ret = env->RegisterNatives(clazz, method_table, sizeof(method_table) / sizeof(method_table[0]));
            env->DeleteLocalRef(clazz);
            return ret == 0 ? JNI_VERSION_1_6 : JNI_ERR;
        } else {
            return JNI_ERR;
        }
    }
}
