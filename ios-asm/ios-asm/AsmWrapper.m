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
