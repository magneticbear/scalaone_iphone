//
//  SOSpeakerListViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SOUniqueTouchView.h"
#import "SOSpeakerCell.h"

typedef enum {
    SOAvatarStateDefault,
    SOAvatarStateFavorite,
    SOAvatarStateAnimatingToDefault,
    SOAvatarStateAnimatingToFavorite,
} SOAvatarState;

@interface SOSpeakerListViewController : SOViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SOUniqueTouchViewDelegate, SOSpeakerCellDelegate> {
    SOAvatarState avatarState;
    SOSpeakerCell *currentCell;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) SOAvatarState avatarState;
@property (weak, nonatomic) SOSpeakerCell *currentCell;

@end
