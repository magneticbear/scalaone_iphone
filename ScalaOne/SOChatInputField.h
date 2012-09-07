//
//  SOChatInputField.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/27/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOInputTextView.h"

@protocol SOInputChatFieldDelegate <NSObject>

- (void)didChangeSOInputChatFieldSize:(CGSize)size;
- (void)didPressSendWithText:(NSString*)text facebook:(BOOL)facebook twitter:(BOOL)twitter;
- (void)didSelectFacebook;
- (void)didSelectTwitter;

@end

@interface SOChatInputField : UIView <UITextFieldDelegate, UITextViewDelegate> {
    SOInputTextView *inputField;
    UIImageView *inputBG;
    UIButton *facebookButton;
    UIButton *twitterButton;
    UIButton *sendButton;
    BOOL shouldSendToFacebook;
    BOOL shouldSendToTwitter;
    id<SOInputChatFieldDelegate> delegate;
    UILabel *charactersLeft;
}

@property (nonatomic) SOInputTextView *inputField;
@property (nonatomic, retain) UIImageView *inputBG;
@property (nonatomic, retain) UIButton *facebookButton;
@property (nonatomic, retain) UIButton *twitterButton;
@property (nonatomic, retain) UIButton *sendButton;
@property (atomic) BOOL shouldSendToFacebook;
@property (atomic) BOOL shouldSendToTwitter;
@property (nonatomic, unsafe_unretained) id<SOInputChatFieldDelegate> delegate;
@property (nonatomic, retain) UILabel *charactersLeft;

@end
