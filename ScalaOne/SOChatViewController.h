//
//  SOChatViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bully/Bully.h>

@class BLYClient;

@interface SOChatViewController : UIViewController <BLYClientDelegate, UITableViewDataSource, UITableViewDelegate> {
    BLYClient *client;
    BLYChannel *chatChannel;
}

@property (nonatomic, retain) BLYClient *client;
@property (nonatomic, retain) BLYChannel *chatChannel;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

- (IBAction)backOne:(id)sender;

@end
