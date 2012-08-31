//
//  SOChatCell.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Allow delegate that catches user icon taps
// TODO: Add auto-size for text bubble with max size (see PSD)
// TODO: Fix SOChatCellAlignmentRight bubble position (should be closer to avatar)
// TODO (Optional): Make input field scrollable when too large to be displayed

#import "SOChatCell.h"

@implementation SOChatTextView

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

@end

@implementation SOChatCell
@synthesize avatarImg = _avatarImg;
@synthesize messageBG = _messageBG;
@synthesize messageTextView = _messageTextView;
@synthesize messageMetaLabel = _messageMetaLabel;
@synthesize cellAlignment = _cellAlignment;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        Initializers
        _avatarImg = [[UIImageView alloc] init];
        _messageBG = [[UIImageView alloc] init];
        _messageTextView = [[SOChatTextView alloc] init];
        _messageMetaLabel = [[UILabel alloc] init];
        
//        Clear background colors
        _avatarImg.backgroundColor = [UIColor clearColor];
        _messageBG.backgroundColor = [UIColor clearColor];
        _messageTextView.backgroundColor = [UIColor clearColor];
        _messageMetaLabel.backgroundColor = [UIColor clearColor];
        
//        Configuration
        _cellAlignment = SOChatCellAlignmentLeft;
        
        _messageTextView.scrollEnabled = FALSE;
        _messageTextView.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        _messageTextView.textColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
        
        [self addSubview:_avatarImg];
        [self addSubview:_messageBG];
        [self addSubview:_messageTextView];
        [self addSubview:_messageMetaLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    
//    Frames
    if (_cellAlignment == SOChatCellAlignmentLeft) {
        _avatarImg.frame = CGRectMake(10, 10, 49, 49);
        _messageBG.frame = CGRectMake(64, 10, 246, 44);
        _messageTextView.frame = CGRectMake(69, 5, 180, 34);
        _messageMetaLabel.frame = CGRectMake(64, 54, 246, 10);
    } else if (_cellAlignment == SOChatCellAlignmentRight) {
        _avatarImg.frame = CGRectMake(266, 10, 49, 49);
        _messageBG.frame = CGRectMake(10, 10, 246, 44);
        _messageTextView.frame = CGRectMake(15, 5, 180, 34);
        _messageMetaLabel.frame = CGRectMake(10, 54, 246, 10);
    }
    
//    Insets
//    _messageTextView.contentInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
//    Content
    if (_cellAlignment == SOChatCellAlignmentLeft) {
        _messageBG.image = [[UIImage imageNamed:@"chat-speech-gray"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 20, 16, 13)];
        _avatarImg.image = [UIImage imageNamed:@"chat-avatar-mo"];
        _messageTextView.textAlignment = UITextAlignmentLeft;
    } else if (_cellAlignment == SOChatCellAlignmentRight) {
        _messageBG.image = [[UIImage imageNamed:@"chat-speech-blue-right"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 13, 16, 20)];
        _avatarImg.image = [UIImage imageNamed:@"chat-avatar-jp"];
        _messageTextView.textAlignment = UITextAlignmentRight;
    }
    
//    Adjust textview size
    CGSize textSize = [_messageTextView.text sizeWithFont:_messageTextView.font constrainedToSize:_messageTextView.frame.size  lineBreakMode:UILineBreakModeWordWrap];
    _messageTextView.frame = CGRectMake(_messageTextView.frame.origin.x, _messageTextView.frame.origin.y, textSize.width+20, textSize.height+100);
    
    NSLog(@"textSize.height: %.2f",textSize.height);
    
//    Adjust BG size
    CGRect messageBGRect = _messageTextView.frame;
    if (_cellAlignment == SOChatCellAlignmentLeft) {
        messageBGRect.origin.x -= 6;
//        messageBGRect.size.width += 6;
    } else if (_cellAlignment == SOChatCellAlignmentRight) {
        
    }
    _messageBG.frame = messageBGRect;

    CGRect selfFrame = self.frame;
    selfFrame.size.height = _messageTextView.frame.size.height + 10;
    self.frame = selfFrame;
}

@end
