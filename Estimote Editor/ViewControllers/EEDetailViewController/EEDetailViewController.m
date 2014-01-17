//
//  EEDetailViewController.m
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "EEDetailViewController.h"

#import <ESTBeacon.h>

#import <libkern/OSAtomic.h>

#import "EEPowerLevelViewController.h"
#import "EEProximityView.h"

@interface EEDetailViewController () <ESTBeaconDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate>
{
	BOOL _standardAlertRequireNavigationPop;
	SEL	_selectorForEditingAlert;
	unsigned int _asyncAction;
	OSSpinLock _asyncActionLock;
	BOOL _isChangingPowerLevel;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *macAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *hardwareVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;

@property (weak, nonatomic) IBOutlet UIButton *powerLevelButton;
@property (weak, nonatomic) IBOutlet UIButton *majorNumberButton;
@property (weak, nonatomic) IBOutlet UIButton *minorNumberButton;
@property (weak, nonatomic) IBOutlet UIButton *advertIntervalButton;
@property (weak, nonatomic) IBOutlet UIButton *proximityUUIDButton;

@property (weak, nonatomic) IBOutlet EEProximityView *proximityView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *userControls;

- (void)updateUI;
- (void)increaseAsyncAction;
- (void)decreaseAsyncAction;

@end

@implementation EEDetailViewController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _asyncActionLock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.activityIndicator.hidesWhenStopped = YES;
	UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
	if (!_isChangingPowerLevel) {
		self.beacon.delegate = self;
		[self increaseAsyncAction];
		[self.beacon connectToBeacon];
		
		[self.userControls setValue:@NO forKey:@"enabled"];
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	if (!_isChangingPowerLevel) {
		[self.beacon disconnectBeacon];
		self.beacon.delegate = nil;
	}
}

- (void)increaseAsyncAction
{
	OSSpinLockLock(&_asyncActionLock);
	_asyncAction++;
	[self.activityIndicator startAnimating];
	OSSpinLockUnlock(&_asyncActionLock);
}
- (void)decreaseAsyncAction
{
	OSSpinLockLock(&_asyncActionLock);
	_asyncAction--;
	if (0 == _asyncAction) {
		[self.activityIndicator stopAnimating];
	}
	OSSpinLockUnlock(&_asyncActionLock);
}

- (void)updateUI
{
	[self increaseAsyncAction];
	self.title = self.beacon.peripheral.name;
	
	self.macAddressLabel.text = self.beacon.macAddress;
	self.rssiLabel.text = [self.beacon.rssi stringValue];
	
	[self increaseAsyncAction];
	[self.beacon readBeaconHardwareVersionWithCompletion:^(NSString *value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote read error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		self.hardwareVersionLabel.text = value;
		[self decreaseAsyncAction];
	}];
	
	[self increaseAsyncAction];
	[self.beacon readBeaconFirmwareVersionWithCompletion:^(NSString *value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote read error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		self.firmwareVersionLabel.text = value;
		[self decreaseAsyncAction];
	}];
	
	[self increaseAsyncAction];
	[self.beacon readBeaconBatteryWithCompletion:^(unsigned short value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote read error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		self.batteryLevelLabel.text = [NSString stringWithFormat:@"%i", value];
		[self decreaseAsyncAction];
	}];
	
	[self increaseAsyncAction];
	[self.beacon readBeaconPowerWithCompletion:^(ESTBeaconPower value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote read error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		[self.powerLevelButton setTitle:[NSString stringWithFormat:@"%i", value]
							   forState:UIControlStateNormal];
		[self decreaseAsyncAction];
	}];
	
	[self increaseAsyncAction];
	[self.beacon readBeaconMajorWithCompletion:^(unsigned short value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote read error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		[self.majorNumberButton setTitle:[NSString stringWithFormat:@"%i", value]
								forState:UIControlStateNormal];
		[self decreaseAsyncAction];
	}];
	
	[self increaseAsyncAction];
	[self.beacon readBeaconMinorWithCompletion:^(unsigned short value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote read error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		[self.minorNumberButton setTitle:[NSString stringWithFormat:@"%i", value]
								forState:UIControlStateNormal];
		[self decreaseAsyncAction];
	}];
	
	[self increaseAsyncAction];
	[self.beacon readBeaconAdvIntervalWithCompletion:^(unsigned short value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote read error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		[self.advertIntervalButton setTitle:[NSString stringWithFormat:@"%i", value]
							  forState:UIControlStateNormal];
		[self decreaseAsyncAction];
	}];
	
	
	[self.proximityUUIDButton setTitle:self.beacon.ibeacon.proximityUUID.UUIDString
							  forState:UIControlStateNormal];
	
	[self.proximityView setProximity:self.beacon.ibeacon.proximity];
	
	[self.userControls setValue:@YES forKey:@"enabled"];
	[self decreaseAsyncAction];
}

#pragma mark - Actions

- (IBAction)editPowerLevelAction:(UIButton*)sender
{
//	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Not yet functionnal"
//													 message:@"This function is ready to work but the API seems broken"
//													delegate:self
//										   cancelButtonTitle:@"OK"
//										   otherButtonTitles:nil];
//	
//	[alert show];
	
	EEPowerLevelViewController *powerLevelEditor = [[EEPowerLevelViewController alloc] initWithStyle:UITableViewStylePlain];
	
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	powerLevelEditor.powerLevel = [[formatter numberFromString:self.powerLevelButton.titleLabel.text] charValue];
	
	powerLevelEditor.completionHandler = ^(EEPowerLevelViewController* editor) {
		[self.navigationController dismissViewControllerAnimated:YES
													  completion:^{
														  _isChangingPowerLevel = NO;
													  }];
		[self editPowerLevelWithValue:editor.powerLevel];
	};
	
	_isChangingPowerLevel = YES;
	[self.navigationController presentViewController:powerLevelEditor
											animated:YES
										  completion:^{
											  
										  }];
}

- (IBAction)editMajorNumberAction:(id)sender
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update Major Number"
													 message:@"Pick a value between 0 and 65 535"
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"Save", nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
	[alert textFieldAtIndex:0].text = self.majorNumberButton.titleLabel.text;
	
	_selectorForEditingAlert = @selector(editMajorNumberWithString:);
	
	[alert show];
}

- (IBAction)editMinorNumberAction:(id)sender
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update Minor Number"
													 message:@"Pick a value between 0 and 65 535"
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK", nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
	[alert textFieldAtIndex:0].text = self.minorNumberButton.titleLabel.text;
	
	_selectorForEditingAlert = @selector(editMinorNumberWithString:);
	
	[alert show];
}

- (IBAction)editAdvertIntervalAction:(id)sender
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update advertising interval"
													 message:@"Pick a value between 50 and 2000 ms"
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK", nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
	[alert textFieldAtIndex:0].text = self.advertIntervalButton.titleLabel.text;
	
	_selectorForEditingAlert = @selector(editAdvertIntervalWithString:);
	
	[alert show];
}

- (IBAction)shareProximityUUIDAction:(id)sender
{
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.beacon.ibeacon.proximityUUID.UUIDString]
																						 applicationActivities:nil];
	
	[self presentViewController:activityViewController
					   animated:YES
					 completion:^{
						 
					 }];
}


- (IBAction)updateFirmware:(id)sender
{
    [self increaseAsyncAction];
	[self.beacon updateBeaconFirmwareWithProgress:^(NSString *value, NSError *error) {
        NSLog(@"Updating %@", value);
    }
									andCompletion:^(NSError *error) {
										if (error) {
											UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote update error"
																							 message:[error localizedDescription]
																							delegate:self
																				   cancelButtonTitle:@"OK"
																				   otherButtonTitles:nil];
											[alert show];
										}
										
										[self updateUI];
										[self decreaseAsyncAction];
									}];
}

#pragma mark - Internal

- (void)editPowerLevelWithValue:(ESTBeaconPower)powerLevel
{
	[self increaseAsyncAction];
	[self.beacon writeBeaconPower:powerLevel withCompletion:^(ESTBeaconPower value, NSError *error) {
		if (error) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Estimote write error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		
		[self updateUI];
		[self decreaseAsyncAction];
	}];
}

- (void)editMajorNumberWithString:(NSString*)majorString
{
	NSNumberFormatter* formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSNumber* number = [formatter numberFromString:majorString];

	[self increaseAsyncAction];
	[self.beacon writeBeaconMajor:[number unsignedShortValue] withCompletion:^(unsigned short value, NSError* error) {
		if (error) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Estimote write error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		
		[self updateUI];
		[self decreaseAsyncAction];
	}];
}

- (void)editMinorNumberWithString:(NSString*)minorString
{
	NSNumberFormatter* formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSNumber* number = [formatter numberFromString:minorString];
	
	[self increaseAsyncAction];
	[self.beacon writeBeaconMinor:[number unsignedShortValue] withCompletion:^(unsigned short value, NSError* error) {
		if (error) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Estimote write error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		
		[self updateUI];
		[self decreaseAsyncAction];
	}];
}

- (void)editAdvertIntervalWithString:(NSString*)frequencyString
{
	NSNumberFormatter* formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSNumber* number = [formatter numberFromString:frequencyString];
	
	[self increaseAsyncAction];
	[self.beacon writeBeaconAdvInterval:[number unsignedShortValue] withCompletion:^(unsigned short value, NSError *error) {
		if (error) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Estimote write error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		
		[self updateUI];
		[self decreaseAsyncAction];
	}];
}

#pragma mark - ESTBeaconDelegate

- (void)beaconConnectionDidFail:(ESTBeacon*)beacon withError:(NSError*)error
{
	/*UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Estimote connection error"
													 message:[error localizedDescription]
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];*/
	_standardAlertRequireNavigationPop = YES;
	//[alert show];
	[self decreaseAsyncAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)beaconConnectionDidSucceeded:(ESTBeacon*)beacon
{
	[self updateUI];
	[self decreaseAsyncAction];
}

- (void)beaconDidDisconnect:(ESTBeacon*)beacon withError:(NSError*)error
{
	/*UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Estimote connection error"
													 message:[error localizedDescription]
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];*/
	_standardAlertRequireNavigationPop = YES;
	//[alert show];
	[self decreaseAsyncAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (UIAlertViewStyleDefault == alertView.alertViewStyle) {
		if (_standardAlertRequireNavigationPop) {
            [self.navigationController popViewControllerAnimated:YES];
        }
	} else if (UIAlertViewStylePlainTextInput == alertView.alertViewStyle) {
		if ([alertView cancelButtonIndex] != buttonIndex) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[self performSelector:_selectorForEditingAlert withObject:[[alertView textFieldAtIndex:0] text]];
#pragma clang diagnostic pop
		}
	}
}

@end
