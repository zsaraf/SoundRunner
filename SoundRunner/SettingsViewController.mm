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

@synthesize instrNames;
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
    [self.view addSubview:tblView];
    self.allSounds = [[AllSounds alloc] init];
    
    self.instruments = @{
        @"Guitar": [NSNumber numberWithInt:2], @"Keys": [NSNumber numberWithInt:3],
        
        
        };
    

	// Do any additional setup after loading the view.
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
    return self.instrNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ];
        
    }
    cell.textLabel.text = [self.instrNames objectAtIndex:indexPath.row];
    return cell;
}


- (IBAction)showMain:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{ }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get name of selected cell
    NSString * name = [self.instrNames objectAtIndex:indexPath.item];
//    Instrument dictValue = [[self.allSounds.allSounds.]
    // look up value for the name in the dictionary
    int dictValue = [[self.instruments objectForKey:name] intValue];
    // set the bank and patch num
    [[SoundRunnerUtil appDelegate].soundGen setBankNumber:0 patchNumber:dictValue];
    
    
    
}



@end
