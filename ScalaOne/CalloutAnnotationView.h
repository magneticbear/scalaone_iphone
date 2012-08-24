//
//  CalloutAnnotationView.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//
//  Based on the work by Jacob Jennings at
//  https://github.com/jacobjennings/JJMapCallout

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SOCalloutProtocols.h"

@interface CalloutAnnotationView : MKAnnotationView 
<SOAnnotationViewProtocol>
{
	MKAnnotationView *_parentAnnotationView;
	MKMapView *_mapView;
	CGRect _endFrame;
	UIView *_contentView;
	CGFloat _yShadowOffset;
	CGPoint _offsetFromParent;
	CGFloat _contentHeight;
}

@property (nonatomic, strong) MKAnnotationView *parentAnnotationView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIView *contentView;

- (void)animateIn;
- (void)animateInStepTwo;
- (void)animateInStepThree;
- (void)setAnnotationAndAdjustMap:(id <MKAnnotation>)annotation;
- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
