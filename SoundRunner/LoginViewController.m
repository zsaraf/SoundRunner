//
//  LoginViewController.m
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "LoginViewController.h"
#import "RunnerViewController.h"
#import "NetworkManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self nextScreen:nil];
    [[NetworkManager instance] sendNewPlayerMessage:textField.text];
    return YES;
}

-(void)viewDidLoad{
    // Listen for keyboard appearances and disappearances
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

-(IBAction)nextScreen:(NSTimer *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    RunnerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"runnerViewController"];
    [self presentViewController:vc animated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
