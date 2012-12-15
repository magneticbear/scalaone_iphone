//
//  SOSpeakerCell.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import "SOSpeakerCell.h"
#import "UIImage+SOAvatar.h"
#import "SDWebImageManager.h"
#import "UIColor+SOAdditions.h"

@implementation SOSpeakerCell
@synthesize speaker = _speaker;
@synthesize favorite = _favorite;
@synthesize delegate = _delegate;

- (id)initWithSpeaker:(SOSpeaker *)aSpeaker favorite:(BOOL)aFavorite {
    _favorite = aFavorite;
    NSString *reuseIdentifier = _favorite ? @"SpeakerCellFavorite" : @"SpeakerCell";
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
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
        self.textLabel.textColor = [UIColor lightBlue];
        self.textLabel.backgroundColor = bgColorView.backgroundColor;
        
        // Accessory Image
        UIImage *accessoryImage = [UIImage imageNamed:@"list-arrow"];
        UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
        [accImageView setFrame:CGRectMake(0, 0, 12, 17)];
        self.accessoryView = accImageView;
        
        // Content
        [self setSpeaker:aSpeaker];
        
        // Make imageView tappable
        if (!_favorite) {
            self.imageView.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
            longPressRecognizer.minimumPressDuration = 0.15f;
            [self.imageView addGestureRecognizer:longPressRecognizer];
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAvatar:)];
            tapRecognizer.numberOfTapsRequired = 1;
            [self.imageView addGestureRecognizer:tapRecognizer];
        }
    }
    return self;
}

- (void)setSpeaker:(SOSpeaker *)aSpeaker {
    _speaker = aSpeaker;
    
    SOAvatarType avatarType = _favorite ? SOAvatarTypeSmall : SOAvatarTypeFavoriteOff;
    
    if (!_favorite && _speaker.favorite.boolValue) {
        avatarType = SOAvatarTypeFavoriteOn;
    }
    
    self.textLabel.text = _speaker.name;
    self.imageView.image = [UIImage avatarWithSource:nil type:avatarType];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:[NSString stringWithFormat:kSOImageURLFormatForSpeaker,kSOAPIHost,_speaker.remoteID.integerValue]]
                     options:0
                    progress:nil
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                       if (finished && !error) self.imageView.image = [UIImage avatarWithSource:image type:avatarType];
                   }];
}

- (void)didTapAvatar:(UIGestureRecognizer *)gestureRecognizer {
    if (_delegate) {
        [_delegate didPressAvatarForCell:self];
    }
}

@end
