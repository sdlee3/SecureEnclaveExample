//
//  SecEnclaveWrapper.h
//  SecureEnclaveExample
//
//  Created by Sindee Lee on 22/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SecEnclaveWrapper : NSObject
- (NSData *)encryptData: (NSData *)data;
- (NSData *)decryptData: (NSData *)data;
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
