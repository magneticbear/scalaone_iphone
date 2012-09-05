//
//  SOSpeakerCell.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOSpeakerCell.h"

@implementation SOSpeakerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier favorite:(BOOL)favorite
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //        Background views
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [self setBackgroundView:bgColorView];
        
        UIView *bgColorViewSelected = [[UIView alloc] init];
        [bgColorViewSelected setBackgroundColor:[UIColor colorWithRed:0.051 green:0.643 blue:0.816 alpha:1]];
        [self setSelectedBackgroundView:bgColorViewSelected];
        
        //        Text Label Setup
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:19.0f];
        self.textLabel.textColor = [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
        self.textLabel.backgroundColor = bgColorView.backgroundColor;
        
        //        Accessory Image
        UIImage *accessoryImage = [UIImage imageNamed:@"list-arrow"];
        UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
        [accImageView setFrame:CGRectMake(0, 0, 12, 17)];
        self.accessoryView = accImageView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
