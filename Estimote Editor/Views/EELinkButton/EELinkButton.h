//
//  EELinkButton.h
//  Estimote Manager
//
//  Created by Valerian Cubero on 21/01/2014.
//  Copyright (c) 2014 Yoann Gini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EELinkButton : UIButton

@property (strong, nonatomic) NSString* url;

- (IBAction)touchUp:(id)sender;

@end
