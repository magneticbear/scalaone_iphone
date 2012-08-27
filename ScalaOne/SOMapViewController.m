//
//  SOMapViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <MapKit/MapKit.h>
#import "SOLocationAnnotation.h"

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
    
    SOLocationAnnotation *locationAnnotation = [[SOLocationAnnotation alloc] initWithLat:38.7f lon:-90.7f name:@"Mo Mozafarian" distance:@"1.2km"];
    [self.mapView addAnnotation:locationAnnotation];
    locationAnnotation.mapView = self.mapView;
    
    [self.mapView setRegion:MKCoordinateRegionMake(locationAnnotation.coordinate, MKCoordinateSpanMake(0.03, 0.03)) animated:YES];
    
    {
        SOLocationAnnotation *locationAnnotation = [[SOLocationAnnotation alloc] initWithLat:38.715f lon:-90.71f name:@"Mo Mozafarian" distance:@"1.2km"];
        [self.mapView addAnnotation:locationAnnotation];
        locationAnnotation.mapView = self.mapView;
    }
    {
        SOLocationAnnotation *locationAnnotation = [[SOLocationAnnotation alloc] initWithLat:38.685f lon:-90.71f name:@"Mo Mozafarian" distance:@"1.2km"];
        [self.mapView addAnnotation:locationAnnotation];
        locationAnnotation.mapView = self.mapView;
    }
    {
        SOLocationAnnotation *locationAnnotation = [[SOLocationAnnotation alloc] initWithLat:38.715f lon:-90.69f name:@"Mo Mozafarian" distance:@"1.2km"];
        [self.mapView addAnnotation:locationAnnotation];
        locationAnnotation.mapView = self.mapView;
    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
//        [locationAnnotation updateAvatar:@"map_avatar_jp"];
//        [locationAnnotation updateName:@"JP Simard"];
//        [locationAnnotation updateDistance:@"200m"];
//        [locationAnnotation updateCoordinate:CLLocationCoordinate2DMake(38.71f, -90.71f) animated:YES];
//        [locationAnnotation updateProfileID:123];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
//        [locationAnnotation updateCoordinate:CLLocationCoordinate2DMake(38.711f, -90.709f) animated:YES];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
//        [locationAnnotation updateCoordinate:CLLocationCoordinate2DMake(38.714f, -90.71f) animated:YES];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
//        [locationAnnotation updateCoordinate:CLLocationCoordinate2DMake(38.713f, -90.704f) animated:YES];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
//        [locationAnnotation updateCoordinate:CLLocationCoordinate2DMake(38.71f, -90.71f) animated:YES];
//    });
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin .y-230.0, aV.frame.size.width, aV.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.45];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [aV setFrame:endFrame];
        [UIView commitAnimations];
    }
}

- (void)didPressLocateMe:(id)sender {
    NSLog(@"didPressLocateMe");
}

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView {
    NSLog(@"INMAPVIEW: didSelectAnnotationViewInMap");
}

- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView {
    NSLog(@"INMAPVIEW: didDeselectAnnotationViewInMap");
}

@end
