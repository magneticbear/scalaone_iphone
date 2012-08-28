//
//  SOLocationAnnotation.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.

#import "SOLocationAnnotation.h"

@implementation SOLocationAnnotation
@synthesize coordinate, mapView, locationView, nameString = _nameString, distanceString = _distanceString, profileID = _profileID, avatarImgName = _avatarImgName;

- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude name:(NSString*)name distance:(NSString *)distance
{
    _coordinate = CLLocationCoordinate2DMake(latitute, longitude);
    _nameString = name;
    _distanceString = distance;
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

- (void)updateCoordinate:(CLLocationCoordinate2D)newCoordinate animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.33f animations:^{
            self.coordinate = newCoordinate;
        }];
    } else {
        self.coordinate = newCoordinate;
    }
}

- (void)updateAvatar:(NSString *)avatar {
    _avatarImgName = avatar;
    locationView.avatarImg.image = [UIImage imageNamed:_avatarImgName];
}

- (void)updateName:(NSString *)name {
    _nameString = name;
    locationView.nameLabel.text = _nameString;
}

- (void)updateDistance:(NSString *)distance {
    _distanceString = distance;
    locationView.distanceLabel.text = _distanceString;
}

- (void)updateProfileID:(NSInteger)aProfileID {
    _profileID = aProfileID;
    locationView.profileID = _profileID;
}

@end
