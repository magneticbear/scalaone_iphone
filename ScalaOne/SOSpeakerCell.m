//
//  SOSpeakerCell.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOSpeakerCell.h"
#import "UIImage+SOAvatar.h"
#import "SDWebImageManager.h"

@implementation SOSpeakerCell
@synthesize speaker = _speaker;
@synthesize favorite = _favorite;

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
        self.textLabel.textColor = [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
        self.textLabel.backgroundColor = bgColorView.backgroundColor;
        
        // Accessory Image
        UIImage *accessoryImage = [UIImage imageNamed:@"list-arrow"];
        UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
        [accImageView setFrame:CGRectMake(0, 0, 12, 17)];
        self.accessoryView = accImageView;
        
        // Content
        [self setSpeaker:aSpeaker];
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
    [manager downloadWithURL:
     [NSURL URLWithString:[NSString stringWithFormat:@"%@assets/img/profile/%d.jpg",kSOAPIHost,_speaker.remoteID.integerValue]]
                    delegate:self
                     options:0
                     success:^(UIImage *image, BOOL cached) {
                         self.imageView.image = [UIImage avatarWithSource:image type:avatarType];
                     } failure:^(NSError *error) {
                         // NSLog(@"Image retrieval failed");
                     }];
}

@end
