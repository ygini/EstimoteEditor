//
//  EEDetailViewController.h
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESTBeacon;

@interface EEDetailViewController : UIViewController

@property (nonatomic, strong) ESTBeacon *beacon;
- (IBAction)updateFirmware:(id)sender;

@end
