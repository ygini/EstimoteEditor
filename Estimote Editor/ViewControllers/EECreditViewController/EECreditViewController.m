//
//  EECreditViewController.m
//  Estimote Editor
//
//  Created by Yoann Gini on 22/01/2014.
//  Copyright (c) 2014 Yoann Gini. All rights reserved.
//

#import "EECreditViewController.h"

@interface EECreditViewController ()

@property (weak, nonatomic) IBOutlet UITextView *contributorsTextView;
@property (weak, nonatomic) IBOutlet UITextView *licenseTextView;

@end

@implementation EECreditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.licenseTextView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LICENSE" ofType:@""]
														  encoding:NSUTF8StringEncoding
															 error:nil];
    
	self.contributorsTextView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CONTRIB" ofType:@""]
														  encoding:NSUTF8StringEncoding
															 error:nil];
}

@end
