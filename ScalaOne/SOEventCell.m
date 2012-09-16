//
//  SOEventCell.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOEventCell.h"

@interface SOEventCell ()

@end

@implementation SOEventCell {
    NSDateFormatter *df;
}
@synthesize event = _event;
@synthesize favorite = _favorite;

- (id)initWithEvent:(SOEvent *)aEvent favorite:(BOOL)aFavorite {
    _favorite = aFavorite;
    NSString *reuseIdentifier = _favorite ? @"EventCellFavorite" : @"EventCell";
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Background views
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [self setBackgroundView:bgColorView];
        
        UIView *bgColorViewSelected = [[UIView alloc] init];
        [bgColorViewSelected setBackgroundColor:[UIColor colorWithRed:0.051 green:0.643 blue:0.816 alpha:1]];
        [self setSelectedBackgroundView:bgColorViewSelected];
        
        // Text Label Setup
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:19.0f];
        self.textLabel.textColor = [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
        self.textLabel.backgroundColor = bgColorView.backgroundColor;
        
        // Detail Text Label Setup
        self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0f];
        self.detailTextLabel.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        self.detailTextLabel.backgroundColor = bgColorView.backgroundColor;
        
        // Accessory Image
        UIImage *accessoryImage = [UIImage imageNamed:@"list-arrow"];
        UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
        [accImageView setFrame:CGRectMake(0, 0, 12, 17)];
        self.accessoryView = accImageView;
        
        // Make imageView tappable
        if (!_favorite) {
            self.imageView.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
            longPressRecognizer.minimumPressDuration = 0.15f;
            [self.imageView addGestureRecognizer:longPressRecognizer];
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapStar:)];
            tapRecognizer.numberOfTapsRequired = 1;
            [self.imageView addGestureRecognizer:tapRecognizer];
        }
        
        // Date formatter
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM. d 'at' h:mma"];
        
        // Content
        [self setEvent:aEvent];
    }
    return self;
}

- (void)setEvent:(SOEvent *)aEvent {
    _event = aEvent;
    
    self.textLabel.text = _event.title;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",[df stringFromDate:_event.start], _event.location];
    
    if (!_favorite) {
        if (_event.favorite.boolValue) {
            self.imageView.image = [UIImage imageNamed:@"list-star-on"];
        } else {
            self.imageView.image = [UIImage imageNamed:@"list-star-off"];
        }
    }
}

- (void)setStar:(BOOL)star {
    if (star) {
        self.imageView.image = [UIImage imageNamed:@"list-star-on"];
        _event.favorite = @YES;
    } else {
        self.imageView.image = [UIImage imageNamed:@"list-star-off"];
        _event.favorite = @NO;
    }
}

- (void)didTapStar:(UITapGestureRecognizer*)g {
    [self setStar:!_event.favorite.boolValue];
}

@end
