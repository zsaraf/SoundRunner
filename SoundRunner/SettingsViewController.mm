//
//  SettingsViewController.mm
//  SoundRunner
//
//  Created by JP Wright on 2/26/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "SettingsViewController.h"
#import "SoundRunnerUtil.h"
#import "RunnerViewController.h"
#import "renderer.h"
#import "AllSounds.h"
#import "Instrument.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize tblView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // add table view
    [self.view addSubview:tblView];
    // init the all the sounds to load in.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AllSounds instance].instruments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ];
        
    }
    
    Instrument * thisInstr = (Instrument *)[[AllSounds instance].instruments objectAtIndex:indexPath.row];
    cell.textLabel.text = thisInstr.name;
    cell.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 1.0 alpha: 1.0];

    return cell;
}


- (IBAction)showMain:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{ }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the instrument
    Instrument * currInstr = (Instrument *)[[AllSounds instance].instruments objectAtIndex:indexPath.item];
    // get its name
    NSString * name = currInstr.name;
    
    // set the bank and patch num for soundGen
    [[SoundRunnerUtil appDelegate].soundGen setBankNumber:currInstr.bankNum patchNumber:currInstr.patchNum];
    
    
    
}



@end
