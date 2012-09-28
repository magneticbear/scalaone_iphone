//
//  SOEventCell.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import <UIKit/UIKit.h>
#import "SOEvent.h"

@interface SOEventCell : UITableViewCell {
    SOEvent *event;
    BOOL favorite;
}

@property (nonatomic, retain) SOEvent *event;
@property (nonatomic) BOOL favorite;

- (id)initWithEvent:(SOEvent *)aEvent favorite:(BOOL)aFavorite;

@end
