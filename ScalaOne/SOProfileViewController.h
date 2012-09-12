//
//  SOProfileViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SOViewController.h"
#import "SOUser.h"

@interface SOProfileViewController : SOViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *nameBox;
@property (weak, nonatomic) IBOutlet UIImageView *avatarEditImg;

- (id)initWithUser:(SOUser *)user;
- (id)initWithMe;

@end
