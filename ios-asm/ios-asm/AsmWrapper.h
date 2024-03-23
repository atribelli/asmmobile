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
