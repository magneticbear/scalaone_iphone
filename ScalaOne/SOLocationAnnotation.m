//
//  SOLocationAnnotation.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//
//  Based on the work by Jacob Jennings at
//  https://github.com/jacobjennings/JJMapCallout

#import "SOLocationAnnotation.h"

@implementation SOLocationAnnotation
@synthesize coordinate, mapView;

- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude;
{
    _coordinate = CLLocationCoordinate2DMake(latitute, longitude);
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
    
    return locationView;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    NSLog(@"\nOld: %f %f New: %f %f", _coordinate.latitude, _coordinate.longitude, newCoordinate.latitude, newCoordinate.longitude);
    _coordinate = newCoordinate;
    [self.mapView addAnnotation:self];
    if(locationView) {
        [locationView setAnnotation:self];
    }
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}


@end
