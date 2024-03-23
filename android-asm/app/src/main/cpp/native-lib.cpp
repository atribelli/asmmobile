#include <jni.h>
#include <string>

#include "hexstr.h"

extern "C" JNIEXPORT jstring

JNICALL
Java_com_example_android_1asm_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    std::string hello = "Hello from C++ and Asm\n";
    std::string value = "The hex value is ";
    std::string hex   = "{error}";

    int  size    = 32;
    char *buffer = (char *) malloc(size);   // Allocate to ensure 16-byte alignment

    if (createHexStr(buffer, size, 0x0123456789abcdef)) {
        hex = buffer;
    }

    free(buffer);

    std::string output = hello + value + hex;
    return env->NewStringUTF(output.c_str());
}
