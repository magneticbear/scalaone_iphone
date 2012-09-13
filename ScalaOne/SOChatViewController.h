//
//  SOChatViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bully/Bully.h>
#import <Accounts/Accounts.h>
#import "SOViewController.h"
#import "DAKeyboardControl.h"
#import "SOChatInputField.h"
#import "SOChatCell.h"

// Social
//#if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")
#import <Social/Social.h>
//#else
#import <Twitter/Twitter.h>
//#endif

@class BLYClient;

@interface SOChatViewController : SOViewController <BLYClientDelegate, UITableViewDataSource, UITableViewDelegate, SOInputChatFieldDelegate, SOChatCellDelegate> {
    BLYClient *client;
    BLYChannel *chatChannel;
    SOChatInputField *chatInputField;
    ACAccount *twitterAccount;
    ACAccount *facebookAccount;
}

@property (nonatomic, retain) BLYClient *client;
@property (nonatomic, retain) BLYChannel *chatChannel;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (nonatomic, retain) SOChatInputField *chatInputField;
@property (nonatomic, retain) ACAccount *twitterAccount;
@property (nonatomic, retain) ACAccount *facebookAccount;

@end
