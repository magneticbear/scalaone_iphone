//
//  SOLocationView.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//
//  Based on the work by Jacob Jennings at
//  https://github.com/jacobjennings/JJMapCallout

#import "SOLocationView.h"

@implementation SOLocationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
{
    if(!(self = [super initWithAnnotation:annotation reuseIdentifier:@"SOLocationView"]))
        return nil;
    
    self.canShowCallout = NO;
    self.image = [UIImage imageNamed:@"map_marker.png"];
    self.centerOffset = CGPointMake(10, -16);
    self.draggable = YES;
    
    return self;
}

- (void)didSelectAnnotationViewInMap:(MKMapView*) mapView;
{
    
    calloutAnnotation = [[SOCalloutAnnotation alloc] initWithLat:self.annotation.coordinate.latitude lon:self.annotation.coordinate.longitude];
    
    calloutAnnotation.parentAnnotationView = self;
    [mapView addAnnotation:calloutAnnotation];
    
}

- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView;
{
    [mapView removeAnnotation:calloutAnnotation];
    calloutAnnotation = nil;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    if(calloutAnnotation) {
        [calloutAnnotation setCoordinate:annotation.coordinate];
    }
    
    [super setAnnotation:annotation];
}

@end
