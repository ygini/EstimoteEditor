//
//  EEPowerLevelViewController.h
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EEPowerLevelViewController;

typedef void(^EEPowerLevelCompletionHandler)(EEPowerLevelViewController* editor);

@interface EEPowerLevelViewController : UITableViewController

@property (nonatomic, strong) NSNumber *powerLevel;
@property (copy) EEPowerLevelCompletionHandler completionHandler;

@end
