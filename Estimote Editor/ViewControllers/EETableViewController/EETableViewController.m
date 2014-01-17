//
//  EETableViewController.m
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "EETableViewController.h"

#import <ESTBeaconManager.h>
#import <ESTBeacon.h>

#import "EEDetailViewController.h"


#define ESTIMOTE_REGION_ALL @"me.gini.estimote.region.all"

@interface EETableViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) NSArray *beacons;
@end

@implementation EETableViewController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		self.beaconManager = [[ESTBeaconManager alloc] init];
		self.beaconManager.delegate = self;
		self.beaconManager.avoidUnknownStateBeacons = YES;
		
		ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithIdentifier:ESTIMOTE_REGION_ALL];
		[self.beaconManager startRangingBeaconsInRegion:region];
	}
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ESTBeaconManagerDelegate

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
	if ([ESTIMOTE_REGION_ALL isEqualToString:[region identifier]]) {
		self.beacons = [beacons sortedArrayUsingComparator:^NSComparisonResult(ESTBeacon *obj1, ESTBeacon *obj2) {
			return [[NSString stringWithFormat:@"%@ - %@ - %@", obj1.ibeacon.proximityUUID.UUIDString, obj1.ibeacon.major, obj1.ibeacon.minor]
					compare:
					[NSString stringWithFormat:@"%@ - %@ - %@", obj2.ibeacon.proximityUUID.UUIDString, obj2.ibeacon.major, obj2.ibeacon.minor]];
		}];
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	ESTBeacon *beacon = [self.beacons objectAtIndex:indexPath.row];
	
    if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	
	cell.textLabel.text = beacon.ibeacon.proximityUUID.UUIDString;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@,%@ (%li)", beacon.ibeacon.major, beacon.ibeacon.minor, (long)beacon.ibeacon.rssi];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ESTBeacon *beacon = [self.beacons objectAtIndex:indexPath.row];
	
	//EEDetailViewController* viewController = [[EEDetailViewController alloc] initWithNibName:@"EEDetailViewController" bundle:nil];
    EEDetailViewController* viewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"detail-vc"];
	viewController.beacon = beacon;
	
	[[self navigationController] pushViewController:viewController animated:YES];
}

@end
