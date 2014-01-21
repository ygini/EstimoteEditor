//
//  EELinkButton.m
//  Estimote Manager
//
//  Created by Valerian Cubero on 21/01/2014.
//  Copyright (c) 2014 Yoann Gini. All rights reserved.
//

#import "EELinkButton.h"

@implementation EELinkButton


- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
        [self initLink];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self initLink];
    }
    return self;
}

- (void)initLink
{
    [self addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)touchUp:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
}

@end
