//
//  SOMapViewController.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import <UIKit/UIKit.h>
#import <Bully/Bully.h>
#import "SOLocationAnnotation.h"
#import "SOViewController.h"

@interface SOMapViewController : SOViewController <BLYClientDelegate, MKMapViewDelegate> {
    BLYClient *client;
    BLYChannel *locationChannel;
}

@property (nonatomic, retain) BLYClient *client;
@property (nonatomic, retain) BLYChannel *locationChannel;
@property (nonatomic, retain) IBOutlet MKMapView* mapView;

@end
