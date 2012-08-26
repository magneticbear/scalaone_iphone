//
//  SOLocationAnnotation.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.

// TODO: Lots of variables duplicated here from SOLocationView
// TODO: Simplify annotation updating (pass in an object)

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SOLocationProtocols.h"
#import "SOLocationView.h"

@interface SOLocationAnnotation : NSObject 
<MKAnnotation, SOAnnotationProtocol>
{
    CLLocationCoordinate2D _coordinate;
    SOLocationView* locationView;
    NSString *avatarImgName;
    NSString *nameString;
    NSString *distanceString;
    NSInteger profileID;
}

@property (nonatomic, strong) MKMapView* mapView;
@property (nonatomic, strong) SOLocationView* locationView;
@property (nonatomic, strong) NSString *avatarImgName;
@property (nonatomic, strong) NSString *nameString;
@property (nonatomic, strong) NSString *distanceString;
@property (atomic) NSInteger profileID;

- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude name:(NSString *)name distance:(NSString *)distance;
- (void)updateAvatar:(NSString *)avatar;
- (void)updateName:(NSString *)name;
- (void)updateDistance:(NSString *)distance;
- (void)updateCoordinate:(CLLocationCoordinate2D)newCoordinate animated:(BOOL)animated;
- (void)updateProfileID:(NSInteger)aProfileID;

@end
