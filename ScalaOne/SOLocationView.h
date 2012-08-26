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
    CLLocationCoordinate2D coordinate;
    CGFloat _yShadowOffset;
    CAShapeLayer *shapeLayer;
    CAShapeLayer *strokeAndShadowLayer;
    UIImageView *avatarImg;
    UIButton *disclosureButton;
    UILabel *nameLabel;
    UILabel *distanceLabel;
    NSInteger profileID;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) UIImageView *avatarImg;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *distanceLabel;
@property (atomic) NSInteger profileID;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
