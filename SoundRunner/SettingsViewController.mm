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
    // set row height
    [self.tblView setRowHeight:75];
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
        [cell.textLabel setFont:[UIFont fontWithName:@"Gill Sans" size:24]];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    Instrument * thisInstr = (Instrument *)[[AllSounds instance].instruments objectAtIndex:indexPath.row];
    cell.textLabel.text = thisInstr.name;
    cell.backgroundColor = thisInstr.color;

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
    
    [SoundRunnerUtil appDelegate].currentInstrument = currInstr;
}



@end
