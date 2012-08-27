//
//  SOChatInputField.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/27/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputTextField.h"

@interface SOChatInputField : UIView <UITextFieldDelegate> {
    InputTextField *inputField;
    UIButton *facebookButton;
    UIButton *twitterButton;
    UIButton *sendButton;
    BOOL shouldSendToFacebook;
    BOOL shouldSendToTwitter;
}

@property (nonatomic) InputTextField *inputField;
@property (nonatomic, retain) UIButton *facebookButton;
@property (nonatomic, retain) UIButton *twitterButton;
@property (nonatomic, retain) UIButton *sendButton;
@property (atomic) BOOL shouldSendToFacebook;
@property (atomic) BOOL shouldSendToTwitter;

@end
