//
//  SOAnnotationProtocol.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//
//  Based on the work by Jacob Jennings at
//  https://github.com/jacobjennings/JJMapCallout

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol SOAnnotationProtocol <NSObject>

- (MKAnnotationView*)annotationViewInMap:(MKMapView*) mapView;

@end

@protocol SOAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView*) mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView;

@end
