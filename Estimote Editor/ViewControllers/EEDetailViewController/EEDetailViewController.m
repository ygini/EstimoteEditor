//
//  EEDetailViewController.m
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "EEDetailViewController.h"

#import <ESTBeacon.h>

@interface EEDetailViewController () <ESTBeaconDelegate, UIAlertViewDelegate>
{
	BOOL _standardAlertRequireNavigationPop;
	SEL	_selectorForEditingAlert;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *macAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

- (void)updateUI;

@end

@implementation EEDetailViewController

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
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.activityIndicator.hidesWhenStopped = YES;
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	
	[self.activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
	self.beacon.delegate = self;
	[self.beacon connectToBeacon];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[self.beacon disconnectBeacon];
	self.beacon.delegate = nil;
}

- (void)updateUI
{
	self.macAddressLabel.text = self.beacon.macAddress;
	self.powerLabel.text = [self.beacon.power stringValue];
	self.majorLabel.text = [self.beacon.major stringValue];
	self.minorLabel.text = [self.beacon.minor stringValue];
	self.rssiLabel.text = [self.beacon.rssi stringValue];
	[self.activityIndicator stopAnimating];
}

#pragma mark - Actions

- (IBAction)editMajorNumberAction:(id)sender {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update Major Number"
													 message:nil
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
	
	_selectorForEditingAlert = @selector(editMajorNumberWithString:);
	
	[alert show];
}

- (IBAction)editMinorNumberAction:(id)sender {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update Minor Number"
													 message:nil
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
	
	_selectorForEditingAlert = @selector(editMinorNumberWithString:);
	
	[alert show];
}

#pragma mark - Internal

- (void)editMajorNumberWithString:(NSString*)majorString
{
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSNumber *number = [formatter numberFromString:majorString];
	
	[self.activityIndicator startAnimating];
	[self.beacon writeBeaconMajor:[number shortValue] withCompletion:^(unsigned int value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote write error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		
		[self updateUI];
	}];
}

- (void)editMinorNumberWithString:(NSString*)minorString
{
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSNumber *number = [formatter numberFromString:minorString];
	
	[self.activityIndicator startAnimating];
	[self.beacon writeBeaconMinor:[number shortValue] withCompletion:^(unsigned int value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote write error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		
		[self updateUI];
	}];
}

#pragma mark - ESTBeaconDelegate

- (void)beaconConnectionDidFail:(ESTBeacon*)beacon withError:(NSError*)error
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote connection error"
													 message:[error localizedDescription]
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	_standardAlertRequireNavigationPop = YES;
	[alert show];
	
	[self.activityIndicator stopAnimating];
}

- (void)beaconConnectionDidSucceeded:(ESTBeacon*)beacon
{
	[self updateUI];
}

- (void)beaconDidDisconnect:(ESTBeacon*)beacon withError:(NSError*)error
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote connection error"
													 message:[error localizedDescription]
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	_standardAlertRequireNavigationPop = YES;
	[alert show];
	
	[self.activityIndicator stopAnimating];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (UIAlertViewStyleDefault == alertView.alertViewStyle)
	{
		if (_standardAlertRequireNavigationPop) [self.navigationController popViewControllerAnimated:YES];
	}
	else if (UIAlertViewStylePlainTextInput == alertView.alertViewStyle)
	{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:_selectorForEditingAlert withObject:[[alertView textFieldAtIndex:0] text]];
#pragma clang diagnostic pop

	}
}

@end
