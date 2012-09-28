//
//  SOMapViewController.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import "SOMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <MapKit/MapKit.h>
#import "SOLocationAnnotation.h"
#import "SOUser.h"
#import "SOHTTPClient.h"
#import "SDImageCache.h"

#define kMoveToLocationAnimationDuration    2.0

@interface SOMapViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *moc;
}
@end

@implementation SOMapViewController
@synthesize mapView = _mapView;
@synthesize client = _client;
@synthesize locationChannel = _locationChannel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = kSOScreenTitleMap;
    
    if (kSOAnalyticsEnabled) {
        MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
        [mixpanel track:self.title];
    }
    
    UIBarButtonItem *locateMeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map-find-btn"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressLocateMe:)];
    self.navigationItem.rightBarButtonItem = locateMeBtn;
    
    moc = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    client = [[BLYClient alloc] initWithAppKey:kSOPusherAPIKey delegate:self];
    locationChannel = [client subscribeToChannelWithName:@"locations"];
    [locationChannel bindToEvent:@"newLocation" block:^(id location) {
        SOUser* user = nil;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc];
        [request setEntity:entity];
        NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", [[location objectForKey:@"userId"] intValue]];
        [request setPredicate:searchFilter];
        
        NSArray *results = [moc executeFetchRequest:request error:nil];
        
        if (results.count > 0) {
            user = [results lastObject];
        } else {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
        }
        
        // Don't update my own location
        if (!user.isMe.boolValue) {
            // User components
            user.remoteID = [NSNumber numberWithInt:[[location objectForKey:@"userId"] intValue]];
            
            // Location components
            user.latitude = [NSNumber numberWithFloat:[[location objectForKey:@"latitude"] floatValue]];
            user.longitude = [NSNumber numberWithFloat:[[location objectForKey:@"longitude"] floatValue]];
            user.locationTime = [NSDate date];
            
            NSError *error = nil;
            if ([moc hasChanges] && ![moc save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            
            [self fetchUserWithID:user.remoteID.integerValue];
        }
    }];
    
    [[SOHTTPClient sharedClient] getLocationsWithSuccess:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                NSArray *users = [[responseDict objectForKey:@"result"] objectForKey:@"users"];
                
                for (NSDictionary *userDict in users) {
                    
                    SOUser* user = nil;
                    
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc];
                    [request setEntity:entity];
                    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", [[userDict objectForKey:@"id"] intValue]];
                    [request setPredicate:searchFilter];
                    
                    NSArray *results = [moc executeFetchRequest:request error:nil];
                    
                    if (results.count > 0) {
                        user = [results lastObject];
                    } else {
                        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
                    }
                    
                    // Don't update my own location
                    if (!user.isMe.boolValue) {
                        // User components
                        user.firstName = [userDict objectForKey:@"firstName"];
                        user.lastName = [userDict objectForKey:@"lastName"];
                        user.remoteID = [NSNumber numberWithInt:[[userDict objectForKey:@"id"] intValue]];
                        user.twitter = [userDict objectForKey:@"twitter"];
                        user.facebook = [userDict objectForKey:@"facebook"];
                        user.phone = [userDict objectForKey:@"phone"];
                        user.email = [userDict objectForKey:@"email"];
                        user.website = [userDict objectForKey:@"website"];
                        
                        // Location components
                        user.latitude = [NSNumber numberWithFloat:[[userDict objectForKey:@"latitude"] floatValue]];
                        user.longitude = [NSNumber numberWithFloat:[[userDict objectForKey:@"longitude"] floatValue]];
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // Sample date format: 2012-01-16T01:38:37.123Z
                        user.locationTime = [df dateFromString:[userDict objectForKey:@"locationTime"]];
                    }
                }
                
                NSError *error = nil;
                if ([moc hasChanges] && ![moc save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
        });
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getLocations failed");
        });
    }];
    
    
    
    [self resetAndFetch];
    [self performSelector:@selector(didPressLocateMe:) withObject:nil afterDelay:1.0];
}

- (void)fetchUserWithID:(NSInteger)userID {
    [[SOHTTPClient sharedClient] getUserWithID:userID success:^(AFJSONRequestOperation *operation, NSDictionary *responseDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                NSDictionary *userDict = [responseDict objectForKey:@"result"];
                
                SOUser* user = nil;
                    
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc];
                [request setEntity:entity];
                NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"remoteID == %d", [[userDict objectForKey:@"id"] intValue]];
                [request setPredicate:searchFilter];
                
                NSArray *results = [moc executeFetchRequest:request error:nil];
                
                if (results.count > 0) {
                    user = [results lastObject];
                } else {
                    user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
                }
                
                // User components
                user.firstName = [userDict objectForKey:@"firstName"];
                user.lastName = [userDict objectForKey:@"lastName"];
                user.remoteID = [NSNumber numberWithInt:[[userDict objectForKey:@"id"] intValue]];
                user.twitter = [userDict objectForKey:@"twitter"];
                user.facebook = [userDict objectForKey:@"facebook"];
                user.phone = [userDict objectForKey:@"phone"];
                user.email = [userDict objectForKey:@"email"];
                user.website = [userDict objectForKey:@"website"];
                
                // Location components
                user.latitude = [NSNumber numberWithFloat:[[userDict objectForKey:@"latitude"] floatValue]];
                user.longitude = [NSNumber numberWithFloat:[[userDict objectForKey:@"longitude"] floatValue]];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // Sample date format: 2012-01-16T01:38:37.123Z
                user.locationTime = [df dateFromString:[userDict objectForKey:@"locationTime"]];
                
                NSError *error = nil;
                if ([moc hasChanges] && ![moc save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
        });
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"getUserWithID failed");
        });
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    _mapView.delegate = nil;
    _mapView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
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
    // Animate pin drops
    NSInteger idx = 0;
    for (SOLocationView *aV in views) {
        CGRect endFrame = aV.frame;
        
        // Convert pin frame relative to mapView for intersection measurement
        CGPoint convertedOrigin = [mapView convertCoordinate:aV.coordinate toPointToView:mapView];
        CGRect convertedFrame = endFrame;
        convertedFrame.origin.x = convertedOrigin.x + aV.centerOffset.x;
        convertedFrame.origin.y = convertedOrigin.y + aV.centerOffset.y;
        
        // If pin is in view, animate
        if (CGRectIntersectsRect(convertedFrame,self.mapView.frame)) {
            // Start animation outside view
            aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y-self.mapView.frame.size.height, aV.frame.size.width, aV.frame.size.height);
            
            [UIView animateWithDuration:0.5f delay:idx*0.1f options:UIViewAnimationCurveEaseOut animations:^{
                aV.frame = endFrame;
            } completion:^(BOOL finished) {
                // Pin drop animation finished
            }];
            // Increase the next animation's delay
            idx++;
        }
    }
}

- (void)didPressLocateMe:(id)sender {
    if (_mapView.userLocation.coordinate.latitude != 0 && _mapView.userLocation.coordinate.longitude != 0) {
        [_mapView setRegion:MKCoordinateRegionMake(_mapView.userLocation.coordinate, MKCoordinateSpanMake(0.2, 0.2)) animated:YES];
        [self mapView:_mapView didUpdateUserLocation:_mapView.userLocation];
    }
}

- (void)getMapPins {
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:_fetchedResultsController.fetchedObjects.count];
    for (SOUser *user in _fetchedResultsController.fetchedObjects) {
        BOOL annotationExists = NO;
        for (id annotation in _mapView.annotations) {
            if ([annotation isKindOfClass:[SOLocationAnnotation class]]) {
                if (((SOLocationAnnotation *)annotation).profileID == user.remoteID.integerValue) {
                    [((SOLocationAnnotation *)annotation) updateUser:user animated:YES];
                    annotationExists = YES;
                    break;
                }
            }
        }
        if (!annotationExists && !user.isMe.boolValue) {
            SOLocationAnnotation *locationAnnotation = [[SOLocationAnnotation alloc] initWithUser:user];
            [annotations addObject:locationAnnotation];
            locationAnnotation.mapView = _mapView;
        }
    }
    [_mapView addAnnotations:annotations];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation.coordinate.latitude != 0 && userLocation.coordinate.longitude != 0) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:moc]];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"isMe == YES && remoteID != nil"]];
        
        NSArray *results = [moc executeFetchRequest:request error:nil];
        
        if (results.count) {
            SOUser *user = [results lastObject];
            // Only update location at most every 10s
            if (!user.locationTime || ([user.locationTime timeIntervalSinceNow] < -10)) {
                user.latitude = [NSNumber numberWithFloat:_mapView.userLocation.location.coordinate.latitude];
                user.longitude = [NSNumber numberWithFloat:_mapView.userLocation.location.coordinate.longitude];
                user.locationTime = [NSDate date];
                NSError *error = nil;
                if (![_fetchedResultsController performFetch:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [[SOHTTPClient sharedClient] updateLocationForUser:user success:^(AFJSONRequestOperation *operation, id responseObject) {
                } failure:^(AFJSONRequestOperation *operation, NSError *error) {
                }];
            }
        }
    }
}

#pragma mark - Core Data

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self getMapPins];
}

- (void)resetAndFetch {
    _fetchedResultsController = nil;
    _fetchedResultsController.fetchRequest.predicate = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc] initWithKey:@"latitude" ascending:YES];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"latitude != nil"]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortOrder]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"Locations"];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
