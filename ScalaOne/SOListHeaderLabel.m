//
//  SOListHeaderLabel.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/29/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOListHeaderLabel.h"

@implementation SOListHeaderLabel

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* mainColor = [UIColor colorWithRed: 0.03 green: 0.25 blue: 0.35 alpha: 0.42];
    UIColor* topColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.28];
    UIColor* bottomColor = [UIColor colorWithRed: 0.43 green: 0.51 blue: 0.56 alpha: 0.75];
    UIColor* textShadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.42];
    
    //// Shadow Declarations
    UIColor* textShadow = textShadowColor;
    CGSize textShadowOffset = CGSizeMake(0, -1);
    CGFloat textShadowBlurRadius = 0;
    
    CGRect mainRect = rect;
    mainRect.size.height -= 1;
    
    //// mainRect Drawing
    UIBezierPath* mainRectPath = [UIBezierPath bezierPathWithRect:mainRect];
    [mainColor setFill];
    [mainRectPath fill];
    
    //// bottomRect Drawing
    UIBezierPath* bottomRectPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, rect.size.height-1, rect.size.width, 1)];
    [bottomColor setFill];
    [bottomRectPath fill];
    
    //// topRect Drawing
    UIBezierPath* topRectPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, rect.size.width, 1)];
    [topColor setFill];
    [topRectPath fill];
    
    //// Text Drawing
    CGRect textRect = CGRectMake(10, 1, 21, 22);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, textShadowOffset, textShadowBlurRadius, textShadow.CGColor);
    [[UIColor whiteColor] setFill];
    [self.text drawInRect: textRect withFont: [UIFont fontWithName: @"HelveticaNeue-CondensedBold" size: 16] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentLeft];
    CGContextRestoreGState(context);
}

@end
