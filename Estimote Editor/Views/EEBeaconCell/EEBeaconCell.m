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
    CGRect frame = self.frame;
    frame.size.height = 60;
    self.frame = frame;
    
    float thirdLineY = self.frame.size.height - 10;
    float thirdLineHeight = 10;
    
    self.thirdLine = [[UILabel alloc] initWithFrame:CGRectMake(15, thirdLineY, self.frame.size.width, thirdLineHeight)];
    [self.thirdLine setFont:[UIFont fontWithName:self.detailTextLabel.font.fontName size:self.detailTextLabel.font.pointSize]];
    [self addSubview:self.thirdLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.textLabel.frame;
    frame.origin.y = 4;
    self.textLabel.frame = frame;
    
    frame = self.detailTextLabel.frame;
    frame.origin.y = 4 + self.textLabel.frame.size.height;
    self.detailTextLabel.frame = frame;
    
    frame = self.thirdLine.frame;
    frame.origin.y = 3 + self.detailTextLabel.frame.origin.y + self.detailTextLabel.frame.size.height;
    self.thirdLine.frame = frame;
}

@end
