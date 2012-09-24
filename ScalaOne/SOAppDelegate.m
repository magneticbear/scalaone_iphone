//
//  SOAppDelegate.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/21/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

////////////////////////
//  TODO: Add support for native URLs
////////////////////////

// scala1://home
// scala1://events
// * scala1://events/{event_id}
// * scala1://events/{event_id}/discussion
// scala1://speakers
// * scala1://speakers/{speaker_id}
// scala1://map
// scala1://favorites
// scala1://users/{user_id}
// scala1://my_profile
// scala1://discussion

////////////////////////
//  Optional TODOs
////////////////////////

// TODO (Optional): Create podspecs for Vendor classes: https://github.com/CocoaPods/Specs#creating-specifications
// TODO (Optional): Pull-to-refresh functionality throughout
// TODO (Optional): App-level location manager and API update
// TODO (Optional): Generic push notification support

#import <Crashlytics/Crashlytics.h>
#import "SOAppDelegate.h"
#import "SOHomeViewController.h"
#import "SOProfileViewController.h"
#import "UIColor+SOAdditions.h"

@implementation SOAppDelegate
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Analytics
    if (kSOAnalyticsEnabled) {
        [Crashlytics startWithAPIKey:kSOCrashlyticsToken];
        [MixpanelAPI sharedAPIWithToken:kSOMixpanelToken];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Configure navigation controller
    navController = [[UINavigationController alloc] initWithRootViewController:[[SOHomeViewController alloc] init]];
    
    ////////////////////////
    // UIAppearance
    ////////////////////////
    
    // Navigation Bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top-bar-repeat"] forBarMetrics:UIBarMetricsDefault];
    
    // Bar Button
    UIImage *barBtn = [[UIImage imageNamed:@"top-bar-btn-stretch"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    [[UIBarButtonItem appearance] setBackgroundImage:barBtn forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *barBtnDown = [[UIImage imageNamed:@"top-bar-btn-stretch-down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    [[UIBarButtonItem appearance] setBackgroundImage:barBtnDown forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    // Back Button
    UIImage *backBtn = [[UIImage imageNamed:@"back-btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBtn forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *backBtnDown = [[UIImage imageNamed:@"back-btn-down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBtnDown forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    // Reset back button when in image picker since we can't remove its text
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTintColor:[UIColor lightBlue]];
    
    // Launch app
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Local URLs

- (void)showProfile:(NSInteger)profileID {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"remoteID == %d",profileID]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    if (results.count) {
        SOProfileViewController *profileVC = [[SOProfileViewController alloc] initWithUser:[results lastObject]];
        [navController pushViewController:profileVC animated:YES];
    }
}

#pragma mark - Core Data

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ScalaOne" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ScalaOne.sqlite"];
    
    // handle db upgrade
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                    initWithManagedObjectModel:[self managedObjectModel]];
    if(![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil URL:storeUrl options:options error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
