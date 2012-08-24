//
//  SOCalloutAnnotation.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//
//  Based on the work by Jacob Jennings at
//  https://github.com/jacobjennings/JJMapCallout

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SOCalloutProtocols.h"
#import "SOLocationView.h"
#import "SOCalloutView.h"

@class SOLocationView;

@interface SOCalloutAnnotation : NSObject 
<MKAnnotation, SOAnnotationProtocol>
{
    CLLocationCoordinate2D _coordinate;
    SOCalloutView* calloutView;    
}

@property (nonatomic, strong) SOLocationView* parentAnnotationView;
@property (nonatomic, strong) MKMapView* mapView;

- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude;

@end
