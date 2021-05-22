//
//  ViewController.m
//  SecureEnclaveExample
//
//  Created by Sindee Lee on 22/5/21.
//

#import "ViewController.h"
#import "SecEnclaveWrapper.h"
#import "KeychainService.h"

@interface ViewController ()
@property(nonatomic) NSString *password;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)saveAndEncryptDataBtn:(id)sender {
    [KeychainService deleteObjectForKey:@"username"];
    [KeychainService deleteObjectForKey:@"password"];
    SecEnclaveWrapper *secEnc = [[SecEnclaveWrapper alloc] init];
    
    //encrypt values from textfield
    NSData *encryptedUsername = [secEnc encryptData:[[_usernameTextField text] dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *encryptedPassword = [secEnc encryptData:[[_passwordTextField text] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //save encrypted values to keychain
    [KeychainService saveToKeychain:encryptedUsername forKey:@"username"];
    [KeychainService saveToKeychain:encryptedPassword forKey:@"password"];
    
    //display encrypted values
    [_encryptedUsernameData setText:[NSString stringWithFormat:@"%@", encryptedUsername]];
    [_encryptedPasswordData setText:[NSString stringWithFormat:@"%@", encryptedPassword]];
    

    //load encrypted data from keychain and display decrypt values
    [_decryptedUsername setText:[NSString stringWithFormat:@"%@", [[NSString alloc] initWithData:[secEnc decryptData:[KeychainService loadFromKeychainWithKey:@"username"]] encoding:NSUTF8StringEncoding]]];

    [_decryptedPassword setText:[NSString stringWithFormat:@"%@", [[NSString alloc] initWithData:[secEnc decryptData:[KeychainService loadFromKeychainWithKey:@"password"]] encoding:NSUTF8StringEncoding]]];
}

-(void)dismissKeyboard
{
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (IBAction)usernameTextFieldDidEndOnExit:(UITextField *)sender {
    [_passwordTextField becomeFirstResponder];
}

- (IBAction)passwordTextFieldDidEndOnExit:(UITextField *)sender {
    [sender resignFirstResponder];
}

@end
