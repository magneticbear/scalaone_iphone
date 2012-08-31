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

@interface SOChatCell : UITableViewCell {
    UIButton *avatarBtn;
    UIImageView *messageBG;
    UILabel *messageTextView;
    UILabel *messageMetaLabel;
    SOChatCellAlignment cellAlignment;
}

@property (nonatomic, retain) UIButton *avatarBtn;
@property (nonatomic, retain) UIImageView *messageBG;
@property (nonatomic, retain) UILabel *messageTextView;
@property (nonatomic, retain) UILabel *messageMetaLabel;
@property (nonatomic) SOChatCellAlignment cellAlignment;

@end
