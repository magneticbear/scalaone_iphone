//
//  SOChatCell.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOChatCell.h"

// Stop UITextView's from being selected
@implementation UITextView (DisableCopyPaste)

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
        
//        Initializers
        _avatarImg = [[UIImageView alloc] init];
        _messageBG = [[UIImageView alloc] init];
        _messageTextView = [[UITextView alloc] init];
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
    [super layoutSubviews];
    
//    Frames
    if (_cellAlignment == SOChatCellAlignmentLeft) {
        _avatarImg.frame = CGRectMake(10, 10, 49, 49);
        _messageBG.frame = CGRectMake(64, 10, 246, 44);
        _messageTextView.frame = CGRectMake(69, 15, 236, 34);
        _messageMetaLabel.frame = CGRectMake(64, 54, 246, 10);
    } else if (_cellAlignment == SOChatCellAlignmentRight) {
        _avatarImg.frame = CGRectMake(266, 10, 49, 49);
        _messageBG.frame = CGRectMake(10, 10, 246, 44);
        _messageTextView.frame = CGRectMake(15, 15, 236, 34);
        _messageMetaLabel.frame = CGRectMake(10, 54, 246, 10);
    }
    
    
//    Insets
    if (_cellAlignment == SOChatCellAlignmentLeft) {
        _messageTextView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
    } else if (_cellAlignment == SOChatCellAlignmentRight) {
        _messageTextView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
    }
    
//    Content
    if (_cellAlignment == SOChatCellAlignmentLeft) {
        _messageBG.image = [[UIImage imageNamed:@"chat-speech-gray"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 20, 16, 13)];
        _avatarImg.image = [UIImage imageNamed:@"chat-avatar-mo"];
    } else if (_cellAlignment == SOChatCellAlignmentRight) {
        _messageBG.image = [[UIImage imageNamed:@"chat-speech-blue-right"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 13, 16, 20)];
        _avatarImg.image = [UIImage imageNamed:@"chat-avatar-jp"];
    }
}

@end
