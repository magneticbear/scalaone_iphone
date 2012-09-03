//
//  SOChatViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bully/Bully.h>
#import "SOViewController.h"
#import "DAKeyboardControl.h"
#import "SOChatInputField.h"
#import "SOChatCell.h"

@class BLYClient;

@interface SOChatViewController : SOViewController <BLYClientDelegate, UITableViewDataSource, UITableViewDelegate, SOInputChatFieldDelegate, SOChatCellDelegate> {
    BLYClient *client;
    BLYChannel *chatChannel;
    SOChatInputField *chatInputField;
}

@property (nonatomic, retain) BLYClient *client;
@property (nonatomic, retain) BLYChannel *chatChannel;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (nonatomic, retain) SOChatInputField *chatInputField;

@end
