//
//  EEBeaconCell.m
//  Estimote Manager
//
//  Created by Valerian Cubero on 22/01/2014.
//  Copyright (c) 2014 Yoann Gini. All rights reserved.
//

#import "EEBeaconCell.h"

@implementation EEBeaconCell

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initThirdLine];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initThirdLine];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initThirdLine];
    }
    return self;
}

- (void)initThirdLine
{
    self.thirdLineHeight = 19;
    self.thirdLine = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.thirdLineHeight)];
}

@end
