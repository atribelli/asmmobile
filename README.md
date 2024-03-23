# asmmobile

Assembly Language on Mobile Devices.  
Inspired by the book "The Art of ARM Assembly" by Randall Hyde.  
https://nostarch.com/art-arm-assembly  

This project provides examples of using assembly language on iOS and Android mobile devices. If you want to learn ARM assembly language but don't have an ARM-based computer, then test code on your ARM-based smartphone or tablet.  

The following documentation assumes that the reader is familiar with using Apple Xcode to create iOS applications, using Google Android Studio to create Android applications, and running their own mobile applications on their own ARM-based smartphone or tablet. The preceding is beyond the scope of this project.

Xcode 15.3 and Android Studio Iguana | 2023.2.1 Patch 1 were used to create these projects. The instructions below may not work with future versions.

# iOS  
Swift code cannot call C code or assembly language code, it can call objective-c code. So we will need an objective-c wrapper around our assembly functions.

Our assembly language code is in hexstr-arm64-v8a.s.
A C header is needed. Create hexstr.h:
```
// hexstr.h

#ifndef hexstr_h
#define hexstr_h

#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif
    bool createHexStr(char *buffer, size_t len, uint64_t value);
#ifdef __cplusplus
}
#endif

#endif  // hexstr_h
```

How the iOS project was created:
- Created ios-asm project, an ios app application, swift language, and swiftui interface.  
- Copied hexstr.h and hexstr-arm64-v8a.s to the subfolder ios-asm/ios-asm/.  
- Added hexstr.h and hexstr-arm64-v8a.s to the project.  
- Created new iOS Objective-C file named AsmWrapper, file type of empty file.  
- Selected the "Create Bridging Header" button on the dialog that pops up.  
- Created new iOS header file named AsmWrapper.  
- Copied Foundation/Foundation.h import from AsmWrapper.m to AsmWrapper.h.  
- In AsmWrapper.m changed Foundation/Foundation.h import to an AsmWrapper.h import.  
- Added hexstr.h include to AsmWrapper.m.  
- Add an AsmWrapper.h import to bridging header ios-asm-Bridging-Header.h:  
```
//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "AsmWrapper.h"
```
- Add an interface definition to AsmWrapper.h to create the prototype for the objective-c wrapper function:
```
//
//  AsmWrapper.h
//  ios-asm
//

#ifndef AsmWrapper_h
#define AsmWrapper_h

#import <Foundation/Foundation.h>

@interface AsmWrapper : NSObject
- (NSString *) getHexString: (UInt64) value;
@end

#endif /* AsmWrapper_h */
```
- Add an objective-c wrapper implementation to AsmWrapper.m:
```
//
//  AsmWrapper.m
//  ios-asm
//

#import "AsmWrapper.h"

#include "hexstr.h"

@implementation AsmWrapper

// This is just an example of calling assembly language.
// With all this overhead any performance advantage is likely lost.
- (NSString *) getHexString: (UInt64) value {
    int      size    = 32;
    char     *buffer = malloc(size);    // Allocate to ensure 16-byte alignment
    NSString *string;
    
    if (createHexStr(buffer, size, value)) {
        string = [NSString stringWithUTF8String: buffer];
    }
    else {
        string = [NSString stringWithFormat:@"{error %p %d}", buffer, size];
    }

    free(buffer);
    
    return string;
}

@end
```
- Updated ContentView.swift to call assembly code:
```
//
//  ContentView.swift
//  ios-asm
//

import SwiftUI

let asmWrapper = AsmWrapper()
let hexString  = asmWrapper.getHexString(0x0123456789abcdef) ?? "{error}"

struct ContentView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("The hex value is " + hexString)
         }
        .padding()
    }
}

#Preview {
    ContentView()
}
```

# Android
Java and Kotlin code can not call assembly language, it is necessary to use the Android NDK (Native code Development Kit) to call C code. So we will need a C wrapper around our assembly code.

Our assembly language code is in hexstr-arm64-v8a.s.
A C header is needed. Create hexstr.h:
```
// hexstr.h

#ifndef hexstr_h
#define hexstr_h

#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif
    bool createHexStr(char *buffer, size_t len, uint64_t value);
#ifdef __cplusplus
}
#endif

#endif  // hexstr_h
```

How the Android project was created:  
- Created android-asm project, a Phone and Tablet application, Native C++, Kotlin language.  
- Copied hexstr.h and hexstr-arm64-v8a.s to the subfolder android-asm/app/src/main/cpp/.  
- Added an ndk section to defaultConfig in android-asm/app/build.gradle.kts to limit targets to 64-bit ARM:
```
    defaultConfig {
        applicationId = "com.example.android_asm"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

```
- Enabled assembly language in android-asm/app/src/main/cpp/CMakeLists.txt:
```
set(can_use_assembler TRUE)
enable_language(ASM)
```

- Added hexstr-arm64-v8a.s to android-asm/app/src/main/cpp/CMakeLists.txt:
```
add_library(${CMAKE_PROJECT_NAME} SHARED
        # List C/C++ source files with relative paths to this CMakeLists.txt.
        hexstr-arm64-v8a.s
        native-lib.cpp)
```
- Updated android-asm/app/src/main/cpp/native-lib.cpp to call assembly code:
```
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
```
# Android Studio configuration problem
Some Android Studio versions will fail to automatically create android-asm/local.properties.
You may receive warnings like:
```
Invalid Gradle JDK configuration found.
```
```
SDK location not found. Define a valid SDK location with an ANDROID_HOME environment variable or by setting the sdk.dir path in your project's local properties file at '/Users/{username}/{local path}/asmmobile/android-asm/local.properties'.
```
If so, select the Android Studio command File | Sync Project with Gradle Files. This should create the missing local.properties file and allow you to build and run the app on your ARM-based device.
