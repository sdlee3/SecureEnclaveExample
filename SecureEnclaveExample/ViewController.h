//
//  ViewController.h
//  SecureEnclaveExample
//
//  Created by Sindee Lee on 22/5/21.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *encryptedUsernameData;
@property (weak, nonatomic) IBOutlet UILabel *encryptedPasswordData;
@property (weak, nonatomic) IBOutlet UILabel *decryptedUsername;
@property (weak, nonatomic) IBOutlet UILabel *decryptedPassword;

@end

