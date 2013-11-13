//
//  EEProximityView.m
//  Estimote Editor
//
//  Created by Yoann Gini on 13/11/2013.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "EEProximityView.h"

@implementation EEProximityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _proximity = -1;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _proximity = -1;
    }
    return self;
}

- (void)setProximity:(CLProximity)proximity
{
	if (_proximity != proximity) {
		_proximity = proximity;
		
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect
{
    CGRect drawingArea = self.bounds;
	
	CGFloat yMiddle = drawingArea.size.height / 2;
	
	CGFloat baseMetric = drawingArea.size.width / 6;
	
	CGFloat xCircleCenter = baseMetric * 2/3;
	
	CGFloat imediateSide = baseMetric*2;
	CGFloat nearSide = imediateSide*2;
	CGFloat farSide = nearSide*2;
	
	CGRect deviceRect = CGRectZero;
	deviceRect.size.width = imediateSide/5;
	deviceRect.size.height = imediateSide/3;
	deviceRect.origin.x = xCircleCenter - deviceRect.size.width/2;
	deviceRect.origin.y = yMiddle - deviceRect.size.height/2;
	
	CGFloat beaconSide = deviceRect.size.width;
	
	CGFloat xBeacon = xCircleCenter;
	
	switch (_proximity) {
		default:
			break;
		case CLProximityUnknown:
			xBeacon += farSide/2 + baseMetric/2;
			break;
			
		case CLProximityFar:
			xBeacon += farSide/2 - baseMetric/2;
			break;
			
		case CLProximityNear:
			xBeacon += nearSide/2 - baseMetric/2;
			break;
			
		case CLProximityImmediate:
			xBeacon += imediateSide/2 - baseMetric/2;
			break;
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Clear drawing area and apply the background color
	CGContextClearRect(context, drawingArea);
	CGContextSetFillColorWithColor(context, [self.backgroundColor CGColor]);
    CGContextFillRect(context, drawingArea);
	
	// Far cicrle
	CGContextBeginPath(context);
	CGContextAddEllipseInRect(context, CGRectMake(xCircleCenter - farSide/2, yMiddle - farSide/2, farSide, farSide));
	
	CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
	CGContextDrawPath(context, kCGPathFill);
	
	// Near cicrle
	CGContextBeginPath(context);
	CGContextAddEllipseInRect(context, CGRectMake(xCircleCenter - nearSide/2, yMiddle - nearSide/2, nearSide, nearSide));
	
	CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
	CGContextDrawPath(context, kCGPathFill);
	
	// Imediate cicrle
	CGContextBeginPath(context);
	CGContextAddEllipseInRect(context, CGRectMake(xCircleCenter - imediateSide/2, yMiddle - imediateSide/2, imediateSide, imediateSide));
	
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
	CGContextDrawPath(context, kCGPathFill);
	
	// Device Square
	CGContextBeginPath(context);
	CGContextAddRect(context, deviceRect);
	
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextDrawPath(context, kCGPathFill);
	
	// Beacon circle
	if (_proximity >= 0) {
		CGContextBeginPath(context);
		CGContextAddEllipseInRect(context, CGRectMake(xBeacon - beaconSide/2, yMiddle - beaconSide/2, beaconSide, beaconSide));
		
		CGContextSetFillColorWithColor(context, [[UIColor cyanColor] CGColor]);
		CGContextDrawPath(context, kCGPathFill);
	}
}

@end
