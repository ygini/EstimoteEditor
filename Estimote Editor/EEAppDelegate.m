//
//  EEAppDelegate.m
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "TestFlight.h"
#import "EEAppDelegate.h"

@implementation EEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"799d9126-b564-47fa-ad3e-384872a269ee"];
    return YES;
}

@end
