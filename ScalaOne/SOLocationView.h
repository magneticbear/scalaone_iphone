//
//  SOLocationView.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SOLocationProtocols.h"

@interface SOLocationView : MKAnnotationView 
<SOAnnotationViewProtocol>

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
