//
//  SOMapViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOLocationAnnotation.h"
#import "SOViewController.h"

@interface SOMapViewController : SOViewController <MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet MKMapView* mapView;

@end
