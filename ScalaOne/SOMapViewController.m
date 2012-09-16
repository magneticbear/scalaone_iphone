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
#import "SOLocation.h"
#import "SOHTTPClient.h"

#define kMoveToLocationAnimationDuration    2.0

@interface SOMapViewController (){
    NSManagedObjectContext *moc;
}

@end

@implementation SOMapViewController
@synthesize mapView = _mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Find an enthusiast";
    UIBarButtonItem *locateMeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map-find-btn"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressLocateMe:)];
    self.navigationItem.rightBarButtonItem = locateMeBtn;
    
    if (DEMO) {
        if (_mapView.userLocation.coordinate.latitude != 0 && _mapView.userLocation.coordinate.longitude != 0) {
            [self didPressLocateMe:nil];
            double delayInSeconds = kMoveToLocationAnimationDuration;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self getMapPins];
            });
        }
    } else {
        moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
//        [[SOHTTPClient sharedClient] getLocationsWithSuccess:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
//                    NSArray *events = [[responseDict objectForKey:@"result"] objectForKey:@"events"];
//                    
//                    for (NSDictionary *eventDict in events) {
//                        
//                        SOEvent* event = nil;
//                        
//                        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//                        
//                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc];
//                        [request setEntity:entity];
//                        NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", [[eventDict objectForKey:@"id"] intValue]];
//                        [request setPredicate:searchFilter];
//                        
//                        NSArray *results = [moc executeFetchRequest:request error:nil];
//                        
//                        if (results.count > 0) {
//                            event = [results lastObject];
//                        } else {
//                            event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
//                        }
//                        
//                        event.title = [eventDict objectForKey:@"title"];
//                        event.remoteID = [NSNumber numberWithInt:[[eventDict objectForKey:@"id"] intValue]];
//                        event.location = [eventDict objectForKey:@"location"];
//                        event.textDescription = [eventDict objectForKey:@"description"];
//                        event.code = [eventDict objectForKey:@"code"];
//                        
//                        //                        Dates
//                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//                        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // Sample date format: 2012-01-16T01:38:37.123Z
//                        event.start = [df dateFromString:(NSString*)[eventDict objectForKey:@"start"]];
//                        event.end = [df dateFromString:(NSString*)[eventDict objectForKey:@"end"]];
//                    }
//                    
//                    NSError *error = nil;
//                    if ([moc hasChanges] && ![moc save:&error]) {
//                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//                    }
//                }
//            });
//        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"getEvents failed");
//            });
//        }];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    _mapView.delegate = nil;
    _mapView = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view {
    if([view conformsToProtocol:@protocol(SOAnnotationViewProtocol)]) {
        [((NSObject<SOAnnotationViewProtocol>*)view) didSelectAnnotationViewInMap:aMapView];
    }
}

- (void)mapView:(MKMapView *)aMapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if([view conformsToProtocol:@protocol(SOAnnotationViewProtocol)]) {
        [((NSObject<SOAnnotationViewProtocol>*)view) didDeselectAnnotationViewInMap:aMapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation conformsToProtocol:@protocol(SOAnnotationProtocol)]) {
        return [((NSObject<SOAnnotationProtocol>*)annotation) annotationViewInMap:aMapView];
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
//    Animate pin drops
    NSInteger idx = 0;
    for (SOLocationView *aV in views) {
        CGRect endFrame = aV.frame;
        
//        Convert pin frame relative to mapView for intersection measurement
        CGPoint convertedOrigin = [mapView convertCoordinate:aV.coordinate toPointToView:mapView];
        CGRect convertedFrame = endFrame;
        convertedFrame.origin.x = convertedOrigin.x + aV.centerOffset.x;
        convertedFrame.origin.y = convertedOrigin.y + aV.centerOffset.y;
        
//        If pin is in view, animate
        if (CGRectIntersectsRect(convertedFrame,self.mapView.frame)) {
//            Start animation outside view
            aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y-self.mapView.frame.size.height, aV.frame.size.width, aV.frame.size.height);
            
            [UIView animateWithDuration:0.5f delay:idx*0.1f options:UIViewAnimationCurveEaseOut animations:^{
                aV.frame = endFrame;
            } completion:^(BOOL finished) {
//                Pin drop animation finished
            }];
//            Increase the next animation's delay
            idx++;
        }
    }
}

- (void)didPressLocateMe:(id)sender {
    if (_mapView.userLocation.coordinate.latitude != 0 && _mapView.userLocation.coordinate.longitude != 0) {
        [_mapView setRegion:MKCoordinateRegionMake(_mapView.userLocation.coordinate, MKCoordinateSpanMake(0.2, 0.2)) animated:YES];
        if (!DEMO) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:moc];
            SOLocation *location = [[SOLocation alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
            location.userID = @168;
            location.latitude = [NSNumber numberWithFloat:_mapView.userLocation.location.coordinate.latitude];
            location.longitude = [NSNumber numberWithFloat:_mapView.userLocation.location.coordinate.longitude];
            [[SOHTTPClient sharedClient] updateLocation:location success:^(AFJSONRequestOperation *operation, id responseObject) {
                NSLog(@"responseObject: %@",responseObject);
            } failure:^(AFJSONRequestOperation *operation, NSError *error) {
                NSLog(@"update location failed");
            }];
        }
    }
}

- (void)getMapPins {
    CLLocationCoordinate2D userLocation = _mapView.userLocation.coordinate;
    [self addAnnotationsWithUserLocation:userLocation];
}

- (void)addAnnotationsWithUserLocation:(CLLocationCoordinate2D)userLocation {
//    Generate 20 random SOLocationView's and add them to the map
    NSInteger numAnnotations = 5;
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:numAnnotations];
    for (int i=0; i<numAnnotations; i++) {
        SOLocationAnnotation *locationAnnotation = [[SOLocationAnnotation alloc] initWithLat:userLocation.latitude+(0.1f-(arc4random()%100)/500.0f) lon:userLocation.longitude+(0.1f-(arc4random()%100)/500.0f) name:@"Mo Mozafarian" distance:@"1.2km"];
        [annotations  addObject:locationAnnotation];
        locationAnnotation.mapView = _mapView;
    }
    [_mapView addAnnotations:annotations];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation.coordinate.latitude != 0 && userLocation.coordinate.longitude != 0) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self didPressLocateMe:nil];
            double delayInSeconds = kMoveToLocationAnimationDuration;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self getMapPins];
            });
        });
    }
}

@end
