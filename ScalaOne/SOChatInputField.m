//
//  SOChatInputField.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/27/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOChatInputField.h"

@implementation SOChatInputField
@synthesize inputField = _inputField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _inputField = [[InputTextField alloc] initWithFrame:CGRectMake(10.0f, 8.0f, self.frame.size.width - 20.0f, 30.0f)];
        
        _inputField.background = [[UIImage imageNamed:@"chat-input-field"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        _inputField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _inputField.autocorrectionType = UITextAutocorrectionTypeNo;
        _inputField.insets = UIEdgeInsetsMake(4, 8, 0, 8);
        _inputField.returnKeyType = UIReturnKeySend;
        _inputField.delegate = self;
        _inputField.placeholder = @"Send a chat";
        [self addSubview:_inputField];
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
    UIColor* lowerShadow = [UIColor colorWithRed: 0.588 green: 0.642 blue: 0.686 alpha: 1];
    UIColor* topHighlight = [UIColor colorWithRed: 0.835 green: 0.863 blue: 0.875 alpha: 1];
    
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
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, rect.size.height-1, rect.size.width, 1)];
    [lowerShadow setFill];
    [rectangle2Path fill];
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, rect.size.width, 1)];
    [topHighlight setFill];
    [rectangle3Path fill];
    
    //// Cleanup
    CGGradientRelease(grayGradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)didPressPost:(id)sender {
    if (_inputField.text.length) {
        _inputField.text = @"";
        [_inputField resignFirstResponder];
    } else {
        [_inputField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    [self didPressPost:self];
    return YES;
}

@end
