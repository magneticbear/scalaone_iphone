//
//  SOCalloutAnnotation.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//
//  Based on the work by Jacob Jennings at
//  https://github.com/jacobjennings/JJMapCallout

#import "SOCalloutAnnotation.h"
#import "SOCalloutView.h"

@implementation SOCalloutAnnotation
@synthesize parentAnnotationView, mapView;

- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude;
{
    _coordinate = CLLocationCoordinate2DMake(latitute, longitude);
    return self;
}

- (MKAnnotationView*)annotationViewInMap:(MKMapView *)aMapView;
{
    if(!calloutView) {
        calloutView = (SOCalloutView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"SOCalloutView"];
        if(!calloutView)
            calloutView = [[SOCalloutView alloc] initWithAnnotation:self];
    } else {
        calloutView.annotation = self;
    }
    calloutView.parentAnnotationView = self.parentAnnotationView;
    
    return calloutView;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
    if(calloutView) {
        [calloutView setAnnotation:self];
    }
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}


@end
