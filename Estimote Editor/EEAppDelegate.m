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
    [TestFlight takeOff:@"c4af3c20-1a16-4ff2-9da8-0ad1e973b642"];
    return YES;
}

@end
