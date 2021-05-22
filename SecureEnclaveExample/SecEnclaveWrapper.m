//
//  SecEnclaveWrapper.m
//  SecureEnclaveExample
//
//  Created by Sindee Lee on 22/5/21.
//

#import "SecEnclaveWrapper.h"

#define newCFDict CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks)

#define kPrivateKeyName @"com.secureenclave.private"
#define kPublicKeyName @"com.secureenclave.public"

@implementation SecEnclaveWrapper
static SecKeyRef publicKeyRef;
static SecKeyRef privateKeyRef;

- (instancetype) init {
    self = [super init];
    if(![self lookupPublicKeyRef] || ![self lookupPrivateKeyRef])
        [self generatePasscodeKeyPair];
    return self;
}

-(SecKeyRef) lookupPublicKeyRef {
    OSStatus sanityCheck = noErr;
    NSData *tag;
    id keyClass;
    if(publicKeyRef != NULL){
        return publicKeyRef;
    }
    tag = [kPublicKeyName dataUsingEncoding:NSUTF8StringEncoding];
    
    keyClass = (__bridge id)kSecAttrKeyClassPublic;
    NSDictionary *queryDict = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                                (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeEC,
                                (__bridge id)kSecAttrApplicationTag: tag,
                                (__bridge id)kSecAttrKeyClass: keyClass,
                                (__bridge id)kSecReturnRef: (__bridge id)kCFBooleanTrue
    };
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, (CFTypeRef *)&publicKeyRef);
    if(sanityCheck != errSecSuccess){
        NSLog(@"Error while retrieving public key");
    }
    return publicKeyRef;
}

- (SecKeyRef) lookupPrivateKeyRef {
    CFMutableDictionaryRef getPrivateKeyRef = newCFDict;
    CFDictionarySetValue(getPrivateKeyRef, kSecClass, kSecClassKey);
    CFDictionarySetValue(getPrivateKeyRef, kSecAttrKeyClass, kSecAttrKeyClassPrivate);
    CFDictionarySetValue(getPrivateKeyRef, kSecAttrLabel, kPrivateKeyName);
    CFDictionarySetValue(getPrivateKeyRef, kSecReturnRef, kCFBooleanTrue);
    OSStatus status = SecItemCopyMatching(getPrivateKeyRef, (CFTypeRef *)&privateKeyRef);
    if(status == errSecItemNotFound)
        return nil;
    return (SecKeyRef)privateKeyRef;
}

- (BOOL) generatePasscodeKeyPair {
    CFErrorRef error = NULL;
    SecAccessControlRef secObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, kSecAccessControlPrivateKeyUsage, &error);
    if(error != errSecSuccess) {
        NSLog(@"Generate key error %@", error);
    }
    return [self generateKeyPairWithAccessControlObject: secObject];
}

- (BOOL) generateKeyPairWithAccessControlObject:(SecAccessControlRef) accessControlRef {
    CFMutableDictionaryRef accessControlDict = newCFDict;
#if !TARGET_IPHONE_SIMULATOR
    CFDictionaryAddValue(accessControlDict, kSecAttrAccessControl, accessControlRef);
#endif
    CFDictionaryAddValue(accessControlDict, kSecAttrIsPermanent, kCFBooleanTrue);
    CFDictionaryAddValue(accessControlDict, kSecAttrLabel, kPrivateKeyName);
    CFMutableDictionaryRef generatePairRef = newCFDict;
#if !TARGET_IPHONE_SIMULATOR
    CFDictionaryAddValue(generatePairRef, kSecAttrTokenID, kSecAttrTokenIDSecureEnclave);
#endif
    CFDictionaryAddValue(generatePairRef, kSecAttrKeyType, kSecAttrKeyTypeEC);
    CFDictionaryAddValue(generatePairRef, kSecAttrKeySizeInBits, (__bridge const void *)([NSNumber numberWithInt:256]));
    CFDictionaryAddValue(generatePairRef, kSecPrivateKeyAttrs, accessControlDict);
       
    OSStatus status = SecKeyGeneratePair(generatePairRef, &publicKeyRef, &privateKeyRef);
       
    if (status != errSecSuccess){
        NSLog(@"Error while generating key pair. %d", (int)status);
        return NO;
    }
    [self savePublicKeyFromRef:publicKeyRef];
    return YES;
}

- (BOOL) savePublicKeyFromRef:(SecKeyRef)publicKeyRef
{
    OSStatus sanityCheck = noErr;
    NSData *tag;
    id keyClass;
    
    tag = [kPublicKeyName dataUsingEncoding:NSUTF8StringEncoding];
    keyClass = (__bridge id) kSecAttrKeyClassPublic;
    
    NSDictionary *saveDict = @{
        
        (__bridge id) kSecClass : (__bridge id) kSecClassKey,
        (__bridge id) kSecAttrKeyType : (__bridge id) kSecAttrKeyTypeEC,
        (__bridge id) kSecAttrApplicationTag : tag,
        (__bridge id) kSecAttrKeyClass : keyClass,
        (__bridge id) kSecValueData : (__bridge NSData *)SecKeyCopyExternalRepresentation(publicKeyRef,nil),
        (__bridge id) kSecAttrKeySizeInBits : [NSNumber numberWithUnsignedInteger:256],
        (__bridge id) kSecAttrEffectiveKeySize : [NSNumber numberWithUnsignedInteger:256],
        (__bridge id) kSecAttrCanDerive : (__bridge id) kCFBooleanFalse,
        (__bridge id) kSecAttrCanEncrypt : (__bridge id) kCFBooleanTrue,
        (__bridge id) kSecAttrCanDecrypt : (__bridge id) kCFBooleanFalse,
        (__bridge id) kSecAttrCanVerify : (__bridge id) kCFBooleanTrue,
        (__bridge id) kSecAttrCanSign : (__bridge id) kCFBooleanFalse,
        (__bridge id) kSecAttrCanWrap : (__bridge id) kCFBooleanTrue,
        (__bridge id) kSecAttrCanUnwrap : (__bridge id) kCFBooleanFalse
    };
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) saveDict, (CFTypeRef *)&publicKeyRef);
    if (sanityCheck != errSecSuccess) {
        NSLog(@"Error while saving public key in keychain.  SanityCheck: %d", (int)sanityCheck);
    }
    
    return publicKeyRef;
}

- (NSData *)encryptData:(NSData *)data {
    if(data && data.length){
        CFDataRef chipher = SecKeyCreateEncryptedData(publicKeyRef, kSecKeyAlgorithmECIESEncryptionStandardX963SHA256AESGCM, (CFDataRef)data, nil);
        return (__bridge NSData *)chipher;
    }else {
        return nil;
    }
}

- (NSData *)decryptData:(NSData *)data {
    if(data && data.length){
        CFDataRef plainData = SecKeyCreateDecryptedData(privateKeyRef, kSecKeyAlgorithmECIESEncryptionStandardX963SHA256AESGCM, (CFDataRef)data, nil);
        return (__bridge NSData *)plainData;
    }else {
        return nil;
    }
}



@end
