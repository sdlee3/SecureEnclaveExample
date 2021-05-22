//
//  KeychainService.m
//  SecureEnclaveExample
//
//  Created by Sindee Lee on 22/5/21.
//

#import "KeychainService.h"

@implementation KeychainService
+ (void)saveToKeychain: (NSData *)value forKey:(NSString *)key{
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString* prefixedKey = [NSString stringWithFormat:@"%@.%@", bundleId, key];
    
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
    keychainItem[(__bridge id)kSecAttrAccount] = prefixedKey;
    keychainItem[(__bridge id)kSecAttrService] = prefixedKey;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, NULL);
    CFTypeRef result;
    if (status == errSecItemNotFound) {
        // Item does not exist, so add
        keychainItem[(__bridge id)kSecValueData] = value;
        OSStatus sts = SecItemAdd((__bridge CFDictionaryRef)keychainItem, &result);
        if(sts != errSecSuccess){
            NSLog(@"Keychain add error code: %d", (int)sts);
            while (sts == errSecDuplicateItem)
            {
                NSLog(@"Keychain duplicate: %d", (int)sts);
                sts = SecItemDelete((__bridge CFDictionaryRef)keychainItem);
            }
            SecItemAdd((__bridge CFDictionaryRef)keychainItem, &result);
        }
    } else {
        // update item if exist
        NSMutableDictionary *attributesToUpdate = [NSMutableDictionary dictionary];
        attributesToUpdate[(__bridge id)kSecValueData] = value;
        OSStatus sts = SecItemUpdate((__bridge CFDictionaryRef)keychainItem, (__bridge CFDictionaryRef)attributesToUpdate);
        if(sts != noErr) {
            NSLog(@"Keychain update error code: %d", (int)sts);
        }
    }
}

+ (NSData *)loadFromKeychainWithKey:(NSString *)key {
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString* prefixedKey = [NSString stringWithFormat:@"%@.%@", bundleId, key];
    
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
    keychainItem[(__bridge id)kSecAttrAccount] = prefixedKey;
    keychainItem[(__bridge id)kSecAttrService] = prefixedKey;
    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    
    CFDictionaryRef result = nil;
    OSStatus sts = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    
    if(sts == noErr) {
        NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
        return resultDict[(__bridge id)kSecValueData];
    } else {
        NSLog(@"Error: data has not yet been stored in keychain_key: %@",key);
        return nil;
    }
}

+ (void)deleteObjectForKey:(NSString *)key {
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString* prefixedKey = [NSString stringWithFormat:@"%@.%@", bundleId, key];
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
    keychainItem[(__bridge id)kSecAttrAccount] = prefixedKey;
    keychainItem[(__bridge id)kSecAttrService] = prefixedKey;
    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    
    OSStatus sts = SecItemDelete((__bridge CFDictionaryRef)keychainItem);
    NSLog(@"Keychain (delete): %d :key:%@", (int)sts, key);
}
@end
