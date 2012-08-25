//
//  SOFavoritesViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SOFavoritesSegmentTypeEvents = 0,
    SOFavoritesSegmentTypeSpeakers = 1,
} SOFavoritesSegmentType;

@interface SOFavoritesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    SOFavoritesSegmentType currentSegment;
}

@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
