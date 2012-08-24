//
//  SOLocationView.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.

#import "SOLocationView.h"

@implementation SOLocationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
{
    if(!(self = [super initWithAnnotation:annotation reuseIdentifier:@"SOLocationView"]))
        return nil;
    
    self.canShowCallout = NO;
    self.image = [UIImage imageNamed:@"map_marker.png"];
    self.centerOffset = CGPointMake(10, -16);
    
    return self;
}

- (void)didSelectAnnotationViewInMap:(MKMapView*) mapView;
{
    NSLog(@"didSelectAnnotationViewInMap");
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width*2, self.frame.size.height);
    }];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView;
{
    NSLog(@"didDeselectAnnotationViewInMap");
}

@end
