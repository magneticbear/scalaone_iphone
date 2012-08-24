//
//  SOLocationView.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "SOLocationProtocols.h"

typedef enum {
    SOLocationViewAnimationDirectionGrow   = 0,
    SOLocationViewAnimationDirectionShrink   = 1
} SOLocationViewAnimationDirection;

@interface SOLocationView : MKAnnotationView <SOAnnotationViewProtocol> {
    CGFloat _yShadowOffset;
    CAShapeLayer *shapeLayer;
    CAShapeLayer *strokeAndShadowLayer;
    UIImageView *avatarImg;
    UIButton *disclosureButton;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
