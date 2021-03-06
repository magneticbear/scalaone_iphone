//
//  SOChatInputField.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/27/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

// TODO (Optional): Make input field scrollable when too large to be displayed

#import "SOChatInputField.h"
#import "UIColor+SOAdditions.h"

@implementation SOChatInputField
@synthesize inputField = _inputField;
@synthesize inputBG = _inputBG;
@synthesize facebookButton = _facebookButton;
@synthesize twitterButton = _twitterButton;
@synthesize sendButton = _sendButton;
@synthesize shouldSendToFacebook = _shouldSendToFacebook;
@synthesize shouldSendToTwitter = _shouldSendToTwitter;
@synthesize delegate = _delegate;
@synthesize charactersLeft = _charactersLeft;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
        _shouldSendToFacebook = NO;
        _shouldSendToTwitter = NO;
        
        // Input field
        _inputField = [[SOInputTextView alloc] initWithFrame:CGRectMake(6.0f, 8.0f, self.frame.size.width - 12.0f, 30.0f)];
        _inputField.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        _inputField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _inputField.autocorrectionType = UITextAutocorrectionTypeNo;
        _inputField.contentInset = UIEdgeInsetsMake(-2, 0, 0, 0);
        _inputField.delegate = self;
        _inputField.placeholder = kSOChatInputPlaceholder;
        [self addSubview:_inputField];
        
        // Input BG
        _inputBG = [[UIImageView alloc] initWithFrame:_inputField.frame];
        _inputBG.image = [[UIImage imageNamed:@"chat-input-field"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        [self insertSubview:_inputBG belowSubview:_inputField];
        
        // Twitter button
        _twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(7, 45, 52, 32)];
        [_twitterButton setBackgroundImage:[UIImage imageNamed:@"chat-twitter-btn"] forState:UIControlStateNormal];
        [_twitterButton setBackgroundImage:[UIImage imageNamed:@"chat-twitter-btn-checked"] forState:UIControlStateHighlighted];
        [_twitterButton addTarget:self action:@selector(didPressTwitter:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_twitterButton];
        
        // Facebook button
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            _facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(66, 45, 52, 32)];
            [_facebookButton setBackgroundImage:[UIImage imageNamed:@"chat-facebook-btn"] forState:UIControlStateNormal];
            [_facebookButton setBackgroundImage:[UIImage imageNamed:@"chat-facebook-btn-checked"] forState:UIControlStateHighlighted];
            [_facebookButton addTarget:self action:@selector(didPressFacebook:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_facebookButton];
        }
        
        // Send button
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(251, 45, 62, 32)];
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"chat-send-btn"] forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"chat-send-btn-down"] forState:UIControlStateHighlighted];
        [_sendButton addTarget:self action:@selector(didPressSend:) forControlEvents:UIControlEventTouchUpInside];
        
        [_sendButton setTitleShadowColor:[UIColor darkBlue] forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        _sendButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self addSubview:_sendButton];
        
        // Characters Left Label
        _charactersLeft = [[UILabel alloc] initWithFrame:CGRectMake(215, 45, 62, 32)];
        _charactersLeft.backgroundColor = [UIColor clearColor];
        _charactersLeft.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        _charactersLeft.textColor = [UIColor darkGrayColor];
        _charactersLeft.shadowColor = [UIColor whiteColor];
        _charactersLeft.shadowOffset = CGSizeMake(0, 1);
        _charactersLeft.text = @"140";
        [self addSubview:_charactersLeft];
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

- (void)didPressSend:(id)sender {
    [_delegate didPressSendWithText:_inputField.text facebook:_shouldSendToFacebook twitter:_shouldSendToTwitter];
    _inputField.text = @"";
    [self textViewDidChange:_inputField];
    [_inputField resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Limit size of textview
    if ((textView.contentSize.height >= 196.0f || [textView.text length] >= 140) && [text length]){
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    CGRect selfFrame = self.frame;
    CGRect inputFrame = _inputField.frame;
    CGRect facebookFrame = _facebookButton.frame;
    CGRect twitterFrame = _twitterButton.frame;
    CGRect sendFrame = _sendButton.frame;
    CGRect charactersFrame = _charactersLeft.frame;
    
    selfFrame.size.height -= inputFrame.size.height;
    selfFrame.origin.y += inputFrame.size.height;
    inputFrame.size.height = textView.contentSize.height-4.0f;
    
    selfFrame.size.height += inputFrame.size.height;
    selfFrame.origin.y -= inputFrame.size.height;
    
    if (selfFrame.size.height >= 82.0f) {
        facebookFrame.origin.y = selfFrame.size.height-37;
        twitterFrame.origin.y = selfFrame.size.height-37;
        sendFrame.origin.y = selfFrame.size.height-37;
        charactersFrame.origin.y = selfFrame.size.height-37;
    } else {
        facebookFrame.origin.y = 45.0f;
        twitterFrame.origin.y = 45.0f;
        sendFrame.origin.y = 45.0f;
        charactersFrame.origin.y = 45.0f;
    }
    
    _inputField.frame = inputFrame;
    _inputBG.frame = inputFrame;
    self.frame = selfFrame;
    
    _facebookButton.frame = facebookFrame;
    _twitterButton.frame = twitterFrame;
    _sendButton.frame = sendFrame;
    _charactersLeft.frame = charactersFrame;
    
    [_delegate didChangeSOInputChatFieldSize:selfFrame.size];
    
    _charactersLeft.text = [NSString stringWithFormat:@"%d",140-_inputField.text.length];
}

- (void)didPressFacebook:(id)sender {
    _shouldSendToFacebook = !_shouldSendToFacebook;
    
    if (_shouldSendToFacebook) {
        [_delegate didSelectFacebook];
        [self performSelector:@selector(doHighlight:) withObject:_facebookButton afterDelay:0];
    }
}

- (void)didPressTwitter:(id)sender {
    _shouldSendToTwitter = !_shouldSendToTwitter;
    
    if (_shouldSendToTwitter) {
        [_delegate didSelectTwitter];
        [self performSelector:@selector(doHighlight:) withObject:_twitterButton afterDelay:0];
    }
}

- (void)doHighlight:(UIButton*)b {
    [b setHighlighted:YES];
}

@end
