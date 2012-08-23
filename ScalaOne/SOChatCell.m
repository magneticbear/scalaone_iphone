//
//  SOChatCell.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOChatCell.h"

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
        _cellAlignment = SOChatCellAlignmentLeft;
        _avatarImg = [[UIImageView alloc] init];
        _messageBG = [[UIImageView alloc] init];
        _messageTextView = [[UITextView alloc] init];
        _messageMetaLabel = [[UILabel alloc] init];
        
        _messageTextView.scrollEnabled = FALSE;
        
        _avatarImg.backgroundColor = [UIColor blueColor];
        _messageBG.backgroundColor = [UIColor blackColor];
        _messageTextView.backgroundColor = [UIColor redColor];
        _messageMetaLabel.backgroundColor = [UIColor brownColor];
        
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
    if (_cellAlignment == SOChatCellAlignmentLeft) {
        _avatarImg.frame = CGRectMake(10, 10, 44, 44);
        _messageBG.frame = CGRectMake(64, 10, 246, 44);
        _messageTextView.frame = CGRectMake(69, 15, 236, 34);
        _messageMetaLabel.frame = CGRectMake(64, 54, 246, 10);
    } else {
        _avatarImg.frame = CGRectMake(266, 10, 44, 44);
        _messageBG.frame = CGRectMake(10, 10, 246, 44);
        _messageTextView.frame = CGRectMake(15, 15, 236, 34);
        _messageMetaLabel.frame = CGRectMake(10, 54, 246, 10);
    }
}

@end
