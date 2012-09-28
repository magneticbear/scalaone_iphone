//
//  SOLocationAnnotation.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import "SOLocationAnnotation.h"
#import "SDWebImageManager.h"
#import "UIImage+SOAvatar.h"

@implementation SOLocationAnnotation
@synthesize coordinate, mapView, locationView, nameString = _nameString, distanceString = _distanceString, profileID = _profileID, avatarImgName = _avatarImgName;

- (id)initWithUser:(SOUser *)aUser
{
    self = [super init];
    if (self) {
        _coordinate = CLLocationCoordinate2DMake(aUser.latitude.floatValue, aUser.longitude.floatValue);
        _nameString = [NSString stringWithFormat:@"%@ %@", aUser.firstName, aUser.lastName];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM. d 'at' h:mma"];
        _distanceString = [df stringFromDate:aUser.locationTime];
        _profileID = aUser.remoteID.integerValue;
    }
    
    return self;
}

- (MKAnnotationView*)annotationViewInMap:(MKMapView*) aMapView;
{
    if(!locationView) {
        locationView = (SOLocationView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"SOLocationView"];
        if(!locationView)
            locationView = [[SOLocationView alloc] initWithAnnotation:self];
    } else {
        locationView.annotation = self;
    }
    locationView.coordinate = _coordinate;
    locationView.nameLabel.text = _nameString;
    locationView.distanceLabel.text = _distanceString;
    locationView.profileID = _profileID;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:
     [NSURL URLWithString:[NSString stringWithFormat:kSOImageURLFormatForUser,kSOAPIHost,_profileID]]
                    delegate:self
                     options:0
                     success:^(UIImage *image, BOOL cached) {
                         locationView.avatarImg.image = [UIImage avatarWithSource:image type:SOAvatarTypeUser];
                     } failure:^(NSError *error) {
                         // NSLog(@"Image retrieval failed");
                     }];
    return locationView;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
    [self.mapView addAnnotation:self];
    if(locationView) {
        locationView.coordinate = newCoordinate;
        [locationView setAnnotation:self];
    }
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (void)updateUser:(SOUser *)aUser animated:(BOOL)animated {
    CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake(aUser.latitude.floatValue, aUser.longitude.floatValue);
    if (animated) {
        [UIView animateWithDuration:0.33f animations:^{
            self.coordinate = newCoordinate;
        }];
    } else {
        self.coordinate = newCoordinate;
    }
    
    _nameString = [NSString stringWithFormat:@"%@ %@", aUser.firstName, aUser.lastName];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM. d 'at' h:mma"];
    _distanceString = [df stringFromDate:aUser.locationTime];
    _profileID = aUser.remoteID.integerValue;
    
    if (locationView) {
        locationView.coordinate = _coordinate;
        locationView.nameLabel.text = _nameString;
        locationView.distanceLabel.text = _distanceString;
        locationView.profileID = _profileID;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:
         [NSURL URLWithString:[NSString stringWithFormat:kSOImageURLFormatForUser,kSOAPIHost,_profileID]]
                        delegate:self
                         options:0
                         success:^(UIImage *image, BOOL cached) {
                             locationView.avatarImg.image = [UIImage avatarWithSource:image type:SOAvatarTypeUser];
                         } failure:^(NSError *error) {
                             // NSLog(@"Image retrieval failed");
                         }];
    }
}

@end
