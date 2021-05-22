//
//  KeychainService.h
//  SecureEnclaveExample
//
//  Created by Sindee Lee on 22/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeychainService : NSObject
+ (void)saveToKeychain:(NSData *)value forKey:(NSString *)key;
+ (NSData *)loadFromKeychainWithKey:(NSString *)key; // Returns nil if key does not exist
+ (void)deleteObjectForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
