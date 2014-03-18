//
//  LoginViewController.h
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameField;

@end
