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

#import "EEBeaconCell.h"
#import "EEDetailViewController.h"
#import "EECreditViewController.h"

#import "EEDataProvider.h"

#import <CoreLocation/CoreLocation.h>

#define REGION_BASE_NAME @"me.gini.estimote.region."

@interface EETableViewController () <ESTBeaconManagerDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableDictionary *beaconsPerRegion;
@property (nonatomic, strong) NSMutableArray *regionList;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation EETableViewController {
    NSArray* search;
    NSArray* searchResults;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
		self.beaconManager = [[ESTBeaconManager alloc] init];
		self.beaconManager.delegate = self;
		self.beaconManager.avoidUnknownStateBeacons = YES;
		
		self.beaconsPerRegion = [NSMutableDictionary new];
		self.regionList = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dataProviderNewRegionIdentifierAddedToHistory:)
													 name:kEEDataProviderNewRegionIdentifierAddedToHistory
												   object:[EEDataProvider sharedInstance]];
	}
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,70,320,44)];
	self.searchBar.delegate = self;
	
	self.tableView.tableHeaderView = self.searchBar;
	
	self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
	self.searchController.searchResultsDataSource = self;
	self.searchController.searchResultsDelegate = self;
	self.searchController.delegate = self;
	
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"About"
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(showCredits)];
	[self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    // Since iOS 8 it needs authorization in a different way
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager performSelector:@selector(requestWhenInUseAuthorization) withObject:nil];
    }

	for (NSString *UUIDString in [[EEDataProvider sharedInstance] regionIdentifierHistory]) {
		[self startRangingRegionWithUUID:UUIDString];
	}
	
	[[[EEDataProvider sharedInstance] regionIdentifierHistory] addObject:ESTIMOTE_PROXIMITY_UUID.UUIDString];
}

#pragma mark - Internal

- (void)dataProviderNewRegionIdentifierAddedToHistory:(NSNotification*)notification
{
	[self startRangingRegionWithUUID:[[notification userInfo] objectForKey:kEEDataProviderNewRegionIdentifierKey]];
}

- (void)startRangingRegionWithUUID:(NSString*)UUIDString
{
	NSString *regionIdentifier = [REGION_BASE_NAME stringByAppendingString:UUIDString];
	if (![self.beaconsPerRegion objectForKey:regionIdentifier]) {
		[self.beaconsPerRegion setObject:[NSMutableArray new] forKey:regionIdentifier];
		[self.regionList addObject:regionIdentifier];
		ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:UUIDString]
													 identifier:regionIdentifier];
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        region.notifyEntryStateOnDisplay = NO;
		
        [self.beaconManager startMonitoringForRegion:region];
        
        [self.beaconManager requestStateForRegion:region];
		[self.beaconManager startRangingBeaconsInRegion:region];
		
	}
}

#pragma mark - API

- (void)showCredits
{
	EECreditViewController * creditViewController = [[EECreditViewController alloc] initWithNibName:@"EECreditViewController" bundle:nil];
	
	[self.navigationController pushViewController:creditViewController animated:YES];
}

#pragma mark - Core Location Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self dataProviderNewRegionIdentifierAddedToHistory:[NSNotification notificationWithName:kEEDataProviderNewRegionIdentifierAddedToHistory object:self userInfo:@{kEEDataProviderNewRegionIdentifierKey: ESTIMOTE_PROXIMITY_UUID.UUIDString}]];
}

#pragma mark - ESTBeaconManagerDelegate

-(void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region {
    NSLog(@"did enter region %@",region);
    [self.beaconManager startRangingBeaconsInRegion:region];
}

-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
	NSMutableArray *beaconsList = nil;
	if ((beaconsList = [self.beaconsPerRegion objectForKey:[region identifier]])) {
		[beaconsList setArray:beacons];
		[beaconsList sortUsingComparator:^NSComparisonResult(ESTBeacon *obj1, ESTBeacon *obj2) {
            if ([obj1.major intValue] != [obj2.major intValue]) {
                return [obj1.major intValue] > [obj2.major intValue];
            }
            return [obj1.minor intValue] > [obj2.minor intValue];
		}];
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.beaconsPerRegion count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [[self.beaconsPerRegion objectForKey:[self.regionList objectAtIndex:section]] count];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.regionList objectAtIndex:section] stringByReplacingOccurrencesOfString:REGION_BASE_NAME withString:@""];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    EEBeaconCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	ESTBeacon* beacon = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        beacon = [searchResults objectAtIndex:indexPath.row];
    } else {
        beacon = [[self.beaconsPerRegion objectForKey:[self.regionList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
    
    if (!cell) {
		cell = [[EEBeaconCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
    
    NSString* proximity = @"Unknown";
	if (beacon.proximity == CLProximityImmediate) {
        proximity = @"Immediate";
    } else if (beacon.proximity == CLProximityNear) {
        proximity = @"Near";
    } else if (beacon.proximity == CLProximityFar) {
        proximity = @"Far";
    }
    
	cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", beacon.major, beacon.minor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%ld)", proximity, (long)beacon.rssi];
    cell.thirdLine.text = beacon.proximityUUID.UUIDString;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self tableView:tableView cellForRowAtIndexPath:indexPath].frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ESTBeacon *beacon = [[self.beaconsPerRegion objectForKey:[self.regionList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
	EEDetailViewController *viewController = [[EEDetailViewController alloc] initWithNibName:@"EEDetailViewController" bundle:nil];
	viewController.beacon = beacon;
	
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
//    NSMutableArray* filtered = [[NSMutableArray alloc] init];
//    for (ESTBeacon* beacon in self.beacons) {
//        if ([[beacon.minor stringValue] rangeOfString:searchText].location != NSNotFound
//			|| [[beacon.major stringValue] rangeOfString:searchText].location != NSNotFound
//			|| [beacon.proximityUUID.UUIDString rangeOfString:searchText].location != NSNotFound) {
//            [filtered addObject:beacon];
//        }
//    }
//    searchResults = filtered;
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
