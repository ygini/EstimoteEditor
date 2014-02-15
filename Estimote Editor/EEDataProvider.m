//
//  EEDataProvider.m
//  Estimote Editor
//
//  Created by Yoann Gini on 26/01/2014.
//  Copyright (c) 2014 Yoann Gini. All rights reserved.
//

#import "EEDataProvider.h"

#define kEEDataProviderRegionIdentifierHistoryKey @"regionIdentifierHistory"

@implementation EEDataProvider

+ (instancetype)sharedInstance
{
	static id sharedInstanceEEDataProvider = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstanceEEDataProvider = [self new];
	});
	
	return sharedInstanceEEDataProvider;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{
																  kEEDataProviderRegionIdentifierHistoryKey: [NSMutableArray new]
																  }];
    }
    return self;
}

-(NSMutableArray *)regionIdentifierHistory
{
	return [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:kEEDataProviderRegionIdentifierHistoryKey];
}

- (void)addRegionIdentifierHistoryObject:(NSString *)object
{
	NSMutableArray *regionIdentifierHistory = self.regionIdentifierHistory;
	if ([regionIdentifierHistory indexOfObject:object] == NSNotFound) {
		[regionIdentifierHistory addObject:object];
		[[NSNotificationCenter defaultCenter] postNotificationName:kEEDataProviderNewRegionIdentifierAddedToHistory object:self userInfo:@{kEEDataProviderNewRegionIdentifierKey: object}];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
