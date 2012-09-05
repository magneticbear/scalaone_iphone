//
//  SOChatCell.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Refactor LayoutSubviews

#import "SOChatCell.h"
#import "SOProfileViewController.h"

@implementation SOChatCell
@synthesize avatarBtn = _avatarBtn;
@synthesize messageBG = _messageBG;
@synthesize messageTextView = _messageTextView;
@synthesize messageMetaLabel = _messageMetaLabel;
@synthesize cellAlignment = _cellAlignment;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        Initializers
        _avatarBtn = [[UIButton alloc] init];
        _messageBG = [[UIImageView alloc] init];
        _messageTextView = [[UILabel alloc] init];
        _messageMetaLabel = [[UILabel alloc] init];
        
//        Clear background colors
        _avatarBtn.backgroundColor = [UIColor clearColor];
        _messageBG.backgroundColor = [UIColor clearColor];
        _messageTextView.backgroundColor = [UIColor clearColor];
        _messageMetaLabel.backgroundColor = [UIColor clearColor];
        
//        Configuration
        _cellAlignment = SOChatCellAlignmentLeft;
        
        _messageTextView.numberOfLines = 0;
        _messageTextView.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        _messageTextView.textColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
        
        [_avatarBtn addTarget:self action:@selector(didPressAvatar:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_avatarBtn];
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
        _avatarBtn.frame = CGRectMake(10, 10, 49, 49);
        _messageTextView.frame = CGRectMake(68, 5, 200, 1000);
        _messageMetaLabel.frame = CGRectMake(64, 54, 246, 10);
    } else if (_cellAlignment == SOChatCellAlignmentRight) {
        _avatarBtn.frame = CGRectMake(260, 10, 49, 49);
        _messageTextView.frame = CGRectMake(0, 5, 200, 1000);
        _messageMetaLabel.frame = CGRectMake(10, 54, 246, 10);
    }
    
//    Content
    if (_cellAlignment == SOChatCellAlignmentLeft) {
        _messageBG.image = [[UIImage imageNamed:@"chat-speech-gray"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 20, 16, 13)];
        [_avatarBtn setBackgroundImage:[UIImage imageNamed:@"chat-avatar-mo"] forState:UIControlStateNormal];
        _messageTextView.textAlignment = UITextAlignmentLeft;
    } else if (_cellAlignment == SOChatCellAlignmentRight) {
        _messageBG.image = [[UIImage imageNamed:@"chat-speech-blue-right"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 13, 16, 20)];
        [_avatarBtn setBackgroundImage:[UIImage imageNamed:@"chat-avatar-jp"] forState:UIControlStateNormal];
        _messageTextView.textAlignment = UITextAlignmentRight;
    }
    
//    Adjust textview size
    CGSize textSize = [_messageTextView.text sizeWithFont:_messageTextView.font constrainedToSize:_messageTextView.frame.size  lineBreakMode:(UILineBreakMode)_messageTextView.contentMode];
    CGRect newMessageTextViewRect = CGRectMake(_messageTextView.frame.origin.x+10, _messageTextView.frame.origin.y, textSize.width, textSize.height+14);
    if (_cellAlignment == SOChatCellAlignmentRight) {
        newMessageTextViewRect.origin.x = 238 - newMessageTextViewRect.size.width;
    }
    if (newMessageTextViewRect.size.height < 50) {
        newMessageTextViewRect.origin.y += 20;
    }
    _messageTextView.frame = newMessageTextViewRect;
    
//    Adjust BG size
    CGRect messageBGRect = _messageTextView.frame;
    if (_cellAlignment == SOChatCellAlignmentLeft) {
        messageBGRect.origin.x -= 16;
        messageBGRect.origin.y += 1;
        messageBGRect.size.width += 28;
    } else if (_cellAlignment == SOChatCellAlignmentRight) {
        messageBGRect.origin.x -= 10;
        messageBGRect.origin.y += 1;
        messageBGRect.size.width += 28;
    }
    _messageBG.frame = messageBGRect;
    
//    Adjust avatar position
    CGRect avatarRect = _avatarBtn.frame;
    avatarRect.origin.y = _messageBG.frame.origin.y+_messageBG.frame.size.height-avatarRect.size.height-3;
    if (_cellAlignment == SOChatCellAlignmentRight) {
        avatarRect.origin.y += 1;
    }
    _avatarBtn.frame = avatarRect;
    
//    Adjust cell frame
    CGRect selfFrame = self.frame;
    selfFrame.size.height = _messageTextView.frame.size.height + 20;
    if (selfFrame.size.height < 65) {
        selfFrame.size.height = 71;
    }
    self.frame = selfFrame;
}

- (void)didPressAvatar:(id)sender {
    [_delegate didSelectAvatar:123];
}

@end
