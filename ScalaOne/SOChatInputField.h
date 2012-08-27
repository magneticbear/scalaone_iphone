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
}

@property (nonatomic) InputTextField *inputField;

@end
