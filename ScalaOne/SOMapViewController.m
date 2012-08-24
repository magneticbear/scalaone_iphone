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
#import "SOCalloutProtocols.h"
#import "SOCalloutView.h"

@interface SOMapViewController ()

@end

@implementation SOMapViewController
@synthesize mapView, locationAnnotation;

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
    self.locationAnnotation = [[SOLocationAnnotation alloc] initWithLat:38.7f lon:-90.7f];
    [self.mapView addAnnotation:self.locationAnnotation];
    self.locationAnnotation.mapView = self.mapView;
    
    [self.mapView setRegion:MKCoordinateRegionMake(self.locationAnnotation.coordinate, MKCoordinateSpanMake(0.03, 0.03)) animated:YES];
    
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

- (IBAction)backOne:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    MKAnnotationView *aV;
    
    for (aV in views) {
        
        if (![aV isKindOfClass:[SOCalloutView class]]) {
            CGRect endFrame = aV.frame;
            
            aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y-230.0, aV.frame.size.width, aV.frame.size.height);
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.45];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [aV setFrame:endFrame];
            [UIView commitAnimations];
        }
    }
}

@end
