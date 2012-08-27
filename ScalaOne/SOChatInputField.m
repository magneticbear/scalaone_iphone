//
//  SOChatInputField.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/27/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOChatInputField.h"

@implementation SOChatInputField
//@synthesize inputField = _inputField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkGray = [UIColor colorWithRed: 0.76 green: 0.79 blue: 0.82 alpha: 1];
    UIColor* lightGray = [UIColor colorWithRed: 0.9 green: 0.92 blue: 0.92 alpha: 1];
    UIColor* lowerShadow = [UIColor colorWithRed: 0.66 green: 0.71 blue: 0.74 alpha: 1];
    UIColor* topHighlight = [UIColor colorWithRed: 0.87 green: 0.89 blue: 0.9 alpha: 1];
    
    //// Gradient Declarations
    NSArray* grayGradientColors = [NSArray arrayWithObjects:
                                   (id)lightGray.CGColor,
                                   (id)darkGray.CGColor, nil];
    CGFloat grayGradientLocations[] = {0, 1};
    CGGradientRef grayGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)grayGradientColors, grayGradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, rect.size.width, rect.size.height)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, grayGradient, CGPointMake(0, 0), CGPointMake(0, rect.size.height), 0);
    CGContextRestoreGState(context);
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, rect.size.height-2, rect.size.width, 2)];
    [lowerShadow setFill];
    [rectangle2Path fill];
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, rect.size.width, 2)];
    [topHighlight setFill];
    [rectangle3Path fill];
    
    //// Cleanup
    CGGradientRelease(grayGradient);
    CGColorSpaceRelease(colorSpace);
}

@end
