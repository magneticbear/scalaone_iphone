//
//  SOFavoritesViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import <UIKit/UIKit.h>
#import "SOViewController.h"

typedef enum {
    SOFavoritesSegmentTypeEvents = 0,
    SOFavoritesSegmentTypeSpeakers = 1,
} SOFavoritesSegmentType;

@interface SOFavoritesViewController : SOViewController <UITableViewDelegate, UITableViewDataSource> {
    SOFavoritesSegmentType currentSegment;
}

@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *segmentEventsBtn;
@property (weak, nonatomic) IBOutlet UIButton *segmentSpeakersBtn;

- (IBAction)didSelectSegment:(UIButton*)sender;

@end
