//
//  EEAppDelegate.m
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "EEAppDelegate.h"
#import "EETableViewController.h"

@implementation EEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[EETableViewController alloc] initWithStyle:UITableViewStylePlain]];
	[(UINavigationController*)self.window.rootViewController navigationBar].translucent = NO;
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
