//
//  EEDataProvider.h
//  Estimote Editor
//
//  Created by Yoann Gini on 26/01/2014.
//  Copyright (c) 2014 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * kEEDataProviderNewRegionIdentifierAddedToHistory = @"kEEDataProviderNewRegionIdentifierAddedToHistory";

static NSString * kEEDataProviderNewRegionIdentifierKey = @"kEEDataProviderNewRegionIdentifierKey";

@interface EEDataProvider : NSObject

@property (nonatomic, readonly) NSMutableArray *regionIdentifierHistory;

+ (instancetype)sharedInstance;

- (void)addRegionIdentifierHistoryObject:(NSString *)object;

@end
