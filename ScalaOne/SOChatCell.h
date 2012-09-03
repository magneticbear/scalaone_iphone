//
//  SOChatCell.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SOChatCellDelegate <NSObject>

- (void)didSelectAvatar:(NSInteger)profileID;

@end

typedef enum {
    SOChatCellAlignmentLeft,
    SOChatCellAlignmentRight,
} SOChatCellAlignment;

@interface SOChatCell : UITableViewCell {
    UIButton *avatarBtn;
    UIImageView *messageBG;
    UILabel *messageTextView;
    UILabel *messageMetaLabel;
    SOChatCellAlignment cellAlignment;
    id<SOChatCellDelegate> delegate;
}

@property (nonatomic, retain) UIButton *avatarBtn;
@property (nonatomic, retain) UIImageView *messageBG;
@property (nonatomic, retain) UILabel *messageTextView;
@property (nonatomic, retain) UILabel *messageMetaLabel;
@property (nonatomic) SOChatCellAlignment cellAlignment;
@property (nonatomic, retain) id<SOChatCellDelegate> delegate;

@end
