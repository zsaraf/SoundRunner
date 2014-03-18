//
//  SettingsViewController.h
//  SoundRunner
//
//  Created by JP Wright on 2/26/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AllSounds.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView * tblView;
    
}

- (IBAction)showMain:(id)sender;

@property (nonatomic, strong) NSArray *instrNames;
@property (nonatomic, strong) AllSounds *allSounds;
@property (nonatomic, retain) UITableView* tblView;
@property (nonatomic, strong) NSDictionary *instruments;


@end
