//
//  SOMapViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Stepped delay in pin drop down animations

#import "SOMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <MapKit/MapKit.h>
#import "SOLocationAnnotation.h"

@implementation NSObject (PerformBlockAfterDelay)

- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay
{
    block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}

@end

@interface SOMapViewController ()

@end

@implementation SOMapViewController
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Find an enthusiast";
    UIBarButtonItem *locateMeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map-find-btn"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressLocateMe:)];
    self.navigationItem.rightBarButtonItem = locateMeBtn;
    
    [self getMapPins];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view {
    if([view conformsToProtocol:@protocol(SOAnnotationViewProtocol)]) {
        [((NSObject<SOAnnotationViewProtocol>*)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)aMapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if([view conformsToProtocol:@protocol(SOAnnotationViewProtocol)]) {
        [((NSObject<SOAnnotationViewProtocol>*)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation conformsToProtocol:@protocol(SOAnnotationProtocol)]) {
        return [((NSObject<SOAnnotationProtocol>*)annotation) annotationViewInMap:mapView];
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *aV in views) {
        CGRect endFrame = aV.frame;
        
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y-230.0, aV.frame.size.width, aV.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.45];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [aV setFrame:endFrame];
        [UIView commitAnimations];
    }
}

- (void)didPressLocateMe:(id)sender {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (void)getMapPins {
    [self performBlock:^{
        CLLocationCoordinate2D userLocation = self.mapView.userLocation.coordinate;
        if (userLocation.latitude != 0 && userLocation.longitude != 0) {
            [self.mapView setRegion:MKCoordinateRegionMake(userLocation, MKCoordinateSpanMake(0.1, 0.1)) animated:YES];
            
            for (int i=0; i<20; i++) {
                [self addAnnotationWithUserLocation:userLocation andDelay:0.2f*i];
            }
        }
    } afterDelay:2.0f];
}

- (void)addAnnotationWithUserLocation:(CLLocationCoordinate2D)userLocation andDelay:(NSTimeInterval)delay {
//    [self performBlock:^{
    SOLocationAnnotation *locationAnnotation = [[SOLocationAnnotation alloc] initWithLat:userLocation.latitude+(0.1f-(arc4random()%100)/500.0f) lon:userLocation.longitude+(0.1f-(arc4random()%100)/500.0f) name:@"Mo Mozafarian" distance:@"1.2km"];
    [self.mapView addAnnotation:locationAnnotation];
    locationAnnotation.mapView = self.mapView;
//    } afterDelay:delay];
}

@end
