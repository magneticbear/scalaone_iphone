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

typedef enum {
    SOProfileCellTypeFirstName = 0,
    SOProfileCellTypeLastName = 1,
    SOProfileCellTypeTwitter = 2,
    SOProfileCellTypeFacebook = 3,
    SOProfileCellTypePhone = 4,
    SOProfileCellTypeEmail = 5,
    SOProfileCellTypeWebsite = 6
} SOProfileCellType;

@interface SOProfileViewController : SOViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    SOUser *currentUser;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *nameBox;
@property (weak, nonatomic) IBOutlet UIImageView *avatarEditImg;
@property (nonatomic, retain) SOUser *currentUser;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (id)initWithUser:(SOUser *)user;
- (id)initWithMe;

@end
