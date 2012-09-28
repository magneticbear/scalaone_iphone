//
//  SOSpeakerCell.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import <UIKit/UIKit.h>
#import "SOSpeaker.h"

@class SOSpeakerCell;

@protocol SOSpeakerCellDelegate <NSObject>

- (void)didPressAvatarForCell:(SOSpeakerCell *)speakerCell;

@end

@interface SOSpeakerCell : UITableViewCell {
    SOSpeaker *speaker;
    BOOL favorite;
    id<SOSpeakerCellDelegate> delegate;
}

@property (nonatomic, retain) SOSpeaker *speaker;
@property (nonatomic) BOOL favorite;
@property (nonatomic, unsafe_unretained) id<SOSpeakerCellDelegate> delegate;

- (id)initWithSpeaker:(SOSpeaker *)aSpeaker favorite:(BOOL)aFavorite;

@end
