//
//  SOLocationAnnotation.h
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

@interface SOLocationAnnotation : NSObject 
<MKAnnotation, SOAnnotationProtocol>
{
    CLLocationCoordinate2D _coordinate;
    SOLocationView* locationView;    
}

@property (nonatomic, strong) MKMapView* mapView;

- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude;

@end
