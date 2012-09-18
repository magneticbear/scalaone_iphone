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
#import <Twitter/Twitter.h>     // iOS 5
#import <Social/Social.h>       // iOS 6+

@class BLYClient;

@interface SOChatViewController : SOViewController <BLYClientDelegate, UITableViewDataSource, UITableViewDelegate, SOInputChatFieldDelegate, SOChatCellDelegate> {
    BLYClient *client;
    BLYChannel *chatChannel;
    SOChatInputField *chatInputField;
    ACAccount *twitterAccount;
    ACAccount *facebookAccount;
    NSInteger myUserID;
}

@property (nonatomic, retain) BLYClient *client;
@property (nonatomic, retain) BLYChannel *chatChannel;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (nonatomic, retain) SOChatInputField *chatInputField;
@property (nonatomic, retain) ACAccount *twitterAccount;
@property (nonatomic, retain) ACAccount *facebookAccount;
@property (nonatomic) NSInteger myUserID;

@end
