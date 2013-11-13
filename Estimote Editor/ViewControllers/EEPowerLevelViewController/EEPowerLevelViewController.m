//
//  EEPowerLevelViewController.m
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "EEPowerLevelViewController.h"

#import <ESTBeacon.h>

@interface EEPowerLevelViewController ()

@property (nonatomic, strong) NSArray *powerLevelList;

@end

@implementation EEPowerLevelViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.powerLevelList = @[[NSNumber numberWithChar:ESTBeaconPowerLevel1],
							[NSNumber numberWithChar:ESTBeaconPowerLevel2],
							[NSNumber numberWithChar:ESTBeaconPowerLevel3],
							[NSNumber numberWithChar:ESTBeaconPowerLevel4],
							[NSNumber numberWithChar:ESTBeaconPowerLevel5],
							[NSNumber numberWithChar:ESTBeaconPowerLevel6],
							[NSNumber numberWithChar:ESTBeaconPowerLevel7],
							[NSNumber numberWithChar:ESTBeaconPowerLevel8]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.powerLevelList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.textLabel.text = [[self.powerLevelList objectAtIndex:indexPath.row] stringValue];
	
	if ([self.powerLevel isEqualToNumber:[self.powerLevelList objectAtIndex:indexPath.row]]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.powerLevel = [self.powerLevelList objectAtIndex:indexPath.row];
	[self.tableView reloadData];
	self.completionHandler(self);
}

@end
