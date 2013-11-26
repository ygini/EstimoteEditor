//
//  EEDetailViewController.m
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "EEDetailViewController.h"

#import <ESTBeacon.h>

#import "EEPowerLevelViewController.h"
#import "EEProximityView.h"

@interface EEDetailViewController () <ESTBeaconDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate>
{
	BOOL _standardAlertRequireNavigationPop;
	SEL	_selectorForEditingAlert;
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
@property (weak, nonatomic) IBOutlet UIButton *frequencyButton;
@property (weak, nonatomic) IBOutlet UIButton *proximityUUIDButton;

@property (weak, nonatomic) IBOutlet EEProximityView *proximityView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *userControls;

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
	
	[self.userControls setValue:@NO forKey:@"enabled"];
}

-(void)viewWillDisappear:(BOOL)animated
{
	self.beacon.delegate = nil;
	[self.beacon disconnectBeacon];
}

- (void)updateUI
{
	self.title = self.beacon.peripheral.name;
	
	self.macAddressLabel.text = self.beacon.macAddress;
	self.rssiLabel.text = [self.beacon.rssi stringValue];
	
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
	}];
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
	}];
	[self.beacon readBeaconBatteryWithCompletion:^(unsigned int value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote read error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		self.batteryLevelLabel.text = [NSString stringWithFormat:@"%i", value];
	}];
	
	[self.beacon readBeaconPowerWithCompletion:^(unsigned int value, NSError *error) {
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
	}];
	[self.beacon readBeaconMajorWithCompletion:^(unsigned int value, NSError *error) {
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
	}];
	[self.beacon readBeaconMinorWithCompletion:^(unsigned int value, NSError *error) {
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
	}];
	[self.beacon readBeaconFrequencyWithCompletion:^(unsigned int value, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote read error"
															 message:[error localizedDescription]
															delegate:self
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			
			[alert show];
		}
		[self.frequencyButton setTitle:[NSString stringWithFormat:@"%i", value]
							  forState:UIControlStateNormal];
	}];
	
	[self.proximityUUIDButton setTitle:self.beacon.ibeacon.proximityUUID.UUIDString
							  forState:UIControlStateNormal];
	
	[self.proximityView setProximity:self.beacon.ibeacon.proximity];
	
	[self.activityIndicator stopAnimating];
	[self.userControls setValue:@YES forKey:@"enabled"];
}

#pragma mark - Actions

- (IBAction)editPowerLevelAction:(UIButton*)sender {
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
	powerLevelEditor.powerLevel = [formatter numberFromString:self.powerLevelButton.titleLabel.text];
	
	powerLevelEditor.completionHandler = ^(EEPowerLevelViewController* editor) {
		[self.navigationController dismissViewControllerAnimated:YES
													  completion:^{
			
		}];
		
		[self.activityIndicator startAnimating];
		[self editPowerLevelWithNumber:editor.powerLevel];
	};
	
	[self.navigationController presentViewController:powerLevelEditor
											animated:YES
										  completion:^{
											  
										  }];
}

- (IBAction)editMajorNumberAction:(id)sender {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update Major Number"
													 message:@"Missing specifications for min and max"
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"Save", nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
	[alert textFieldAtIndex:0].text = self.majorNumberButton.titleLabel.text;
	
	_selectorForEditingAlert = @selector(editMajorNumberWithString:);
	
	[alert show];
}

- (IBAction)editMinorNumberAction:(id)sender {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update Minor Number"
													 message:@"Missing specifications for min and max"
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK", nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
	[alert textFieldAtIndex:0].text = self.minorNumberButton.titleLabel.text;
	
	_selectorForEditingAlert = @selector(editMinorNumberWithString:);
	
	[alert show];
}

- (IBAction)editFrequencyAction:(id)sender {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update frequency"
													 message:@"Missing specification for accepted values"
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK", nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
	[alert textFieldAtIndex:0].text = self.frequencyButton.titleLabel.text;
	
	_selectorForEditingAlert = @selector(editFrequencyWithString:);
	
	[alert show];
}

- (IBAction)shareProximityUUIDAction:(id)sender {
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.beacon.ibeacon.proximityUUID.UUIDString]
																						 applicationActivities:nil];
	
	[self presentViewController:activityViewController
					   animated:YES
					 completion:^{
						 
					 }];
}

#pragma mark - Internal

- (void)editPowerLevelWithNumber:(ESTBeaconPower)powerLevel
{
	[self.activityIndicator startAnimating];
	[self.beacon writeBeaconPower:powerLevel withCompletion:^(unsigned int value, NSError *error) {
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

- (void)editMajorNumberWithString:(NSString*)majorString
{
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSNumber *number = [formatter numberFromString:majorString];
    
	[self.activityIndicator startAnimating];
	[self.beacon writeBeaconMajor:[number intValue] withCompletion:^(unsigned int value, NSError *error) {
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
	[self.beacon writeBeaconMinor:[number intValue] withCompletion:^(unsigned int value, NSError *error) {
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

- (void)editFrequencyWithString:(NSString*)frequencyString
{
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSNumber *number = [formatter numberFromString:frequencyString];
	
	[self.activityIndicator startAnimating];
	[self.beacon writeBeaconFrequency:[number shortValue] withCompletion:^(unsigned int value, NSError *error) {
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
		if ([alertView cancelButtonIndex] != buttonIndex) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[self performSelector:_selectorForEditingAlert withObject:[[alertView textFieldAtIndex:0] text]];
#pragma clang diagnostic pop
		}
		
	}
}

- (IBAction)updateFirmware:(id)sender {
    
    [self.activityIndicator startAnimating];
	[self.beacon updateBeaconFirmwareWithProgress:^(NSString *value, NSError *error) {
        NSLog(@"Updating");
    } andCompletion:^(NSError *error) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Estimote update error"
                                                         message:[error localizedDescription]
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        
        [alert show];
    }];
     
		
     [self updateUI];
    
}
@end
