//
//  SOChatCell.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SOChatCellAlignmentLeft   = 0,
    SOChatCellAlignmentRight   = 1
} SOChatCellAlignment;

// Stop UITextView's from being selected
@interface SOChatTextView : UITextView

@end

@interface SOChatCell : UITableViewCell {
    UIImageView *avatarImg;
    UIImageView *messageBG;
    SOChatTextView *messageTextView;
    UILabel *messageMetaLabel;
    SOChatCellAlignment cellAlignment;
}

@property (nonatomic, retain) UIImageView *avatarImg;
@property (nonatomic, retain) UIImageView *messageBG;
@property (nonatomic, retain) SOChatTextView *messageTextView;
@property (nonatomic, retain) UILabel *messageMetaLabel;
@property (nonatomic) SOChatCellAlignment cellAlignment;

@end
