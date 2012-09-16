//
//  SOSpeakerCell.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSpeaker.h"

@interface SOSpeakerCell : UITableViewCell {
    SOSpeaker *speaker;
    BOOL favorite;
}

@property (nonatomic, retain) SOSpeaker *speaker;
@property (nonatomic) BOOL favorite;

- (id)initWithSpeaker:(SOSpeaker *)aSpeaker favorite:(BOOL)aFavorite;

@end
