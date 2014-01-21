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

@implementation EETableViewController {
    NSArray* search;
    NSArray* searchResults;
}

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

-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
	if ([ESTIMOTE_REGION_ALL isEqualToString:[region identifier]]) {
		self.beacons = [beacons sortedArrayUsingComparator:^NSComparisonResult(ESTBeacon *obj1, ESTBeacon *obj2) {
            if ([obj1.ibeacon.major intValue] != [obj2.ibeacon.major intValue]) {
                return [obj1.ibeacon.major intValue] > [obj2.ibeacon.major intValue];
            }
            return [obj1.ibeacon.minor intValue] > [obj2.ibeacon.minor intValue];
		}];
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [self.beacons count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	ESTBeacon* beacon = [self.beacons objectAtIndex:indexPath.row];
    
    if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
    
    NSString* proximity = @"Unknown";
	if (beacon.ibeacon.proximity == CLProximityImmediate) {
        proximity = @"Immediate";
    } else if (beacon.ibeacon.proximity == CLProximityNear) {
        proximity = @"Near";
    } else if (beacon.ibeacon.proximity == CLProximityFar) {
        proximity = @"Far";
    }
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ . %@", beacon.ibeacon.major, beacon.ibeacon.minor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%li)", proximity, (long)beacon.ibeacon.rssi];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ESTBeacon* beacon = [self.beacons objectAtIndex:indexPath.row];
	
    EEDetailViewController* viewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"detail-vc"];
	viewController.beacon = beacon;
	
	[[self navigationController] pushViewController:viewController animated:YES];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSMutableArray* filtered = [[NSMutableArray alloc] init];
    for (ESTBeacon* beacon in self.beacons) {
        if ([[beacon.ibeacon.minor stringValue] rangeOfString:searchText].location != NSNotFound || [[beacon.ibeacon.major stringValue] rangeOfString:searchText].location != NSNotFound) {
            [filtered addObject:beacon];
        }
    }
    searchResults = filtered;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

@end
