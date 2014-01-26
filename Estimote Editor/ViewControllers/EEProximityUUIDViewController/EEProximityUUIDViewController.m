//
//  EEProximityUUIDViewController.m
//  Estimote Editor
//
//  Created by Yoann Gini on 25/01/2014.
//  Copyright (c) 2014 Yoann Gini. All rights reserved.
//

#import "EEProximityUUIDViewController.h"
#import <ESTBeacon.h>
#import <libkern/OSAtomic.h>
#import "EEDataProvider.h"

@interface EEProximityUUIDViewController ()
{
	SEL	_selectorForEditingAlert;
	unsigned int _asyncAction;
	OSSpinLock _asyncActionLock;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *UUIDTextView;

@end

@implementation EEProximityUUIDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
	[self updateUI];
}

#pragma mark - UI management

-(void)updateUI
{
	self.UUIDTextView.text = self.beacon.proximityUUID.UUIDString;
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

#pragma mark - Actions

- (IBAction)editAction:(id)sender
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Edit UUID"
													 message:@"Please, choose your UUID"
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK", nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert textFieldAtIndex:0].text = self.UUIDTextView.text;
	
	_selectorForEditingAlert = @selector(editValueWithString:);
	
	[alert show];
}

- (IBAction)generateAction:(id)sender
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"UUID generation"
													 message:@"Here is a new UUID, do you want to use it?"
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK", nil];
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert textFieldAtIndex:0].text = [[NSUUID UUID] UUIDString];
	
	_selectorForEditingAlert = @selector(editValueWithString:);
	
	[alert show];
}

#pragma mark - Internal

-(void)editValueWithString:(NSString*)UUIDString
{
	[self increaseAsyncAction];
	[self.beacon writeBeaconProximityUUID:UUIDString withCompletion:^(NSString *value, NSError *error) {
		if (error) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Estimote write error"
															message:[error localizedDescription]
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			
			[alert show];
		}
		[[EEDataProvider sharedInstance] addRegionIdentifierHistoryObject:self.beacon.proximityUUID.UUIDString];
		[self updateUI];
		[self decreaseAsyncAction];
	}];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (UIAlertViewStylePlainTextInput == alertView.alertViewStyle) {
		if ([alertView cancelButtonIndex] != buttonIndex) {
			NSString *userInput = [[alertView textFieldAtIndex:0] text];
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:_selectorForEditingAlert]];
			invocation.target = self;
			invocation.selector = _selectorForEditingAlert;
			[invocation setArgument:&userInput atIndex:2];
			[invocation invoke];
		}
	}
}

@end
