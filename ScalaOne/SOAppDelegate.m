//
//  SOAppDelegate.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/21/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOAppDelegate.h"

#import "SOHomeViewController.h"
#import "SOProfileViewController.h"

@implementation SOAppDelegate
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
//    Configure navigation controller
    navController = [[UINavigationController alloc] initWithRootViewController:[[SOHomeViewController alloc] initWithNibName:@"SOHomeViewController" bundle:nil]];
    
////////////////////////
//    UIAppearance
////////////////////////
    
//    Navigation Bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top-bar-repeat"] forBarMetrics:UIBarMetricsDefault];
    
//    Bar Button
    UIImage *barBtn = [[UIImage imageNamed:@"top-bar-btn-stretch"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    [[UIBarButtonItem appearance] setBackgroundImage:barBtn forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *barBtnDown = [[UIImage imageNamed:@"top-bar-btn-stretch-down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    [[UIBarButtonItem appearance] setBackgroundImage:barBtnDown forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
//    Back Button
    UIImage *backBtn = [[UIImage imageNamed:@"back-btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBtn forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *backBtnDown = [[UIImage imageNamed:@"back-btn-down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBtnDown forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
//    Launch app
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Local URLs

- (void)showProfile:(NSInteger)profileID {
    SOProfileViewController *profileVC = [[SOProfileViewController alloc] initWithNibName:@"SOProfileViewController" bundle:nil];
    [navController pushViewController:profileVC animated:YES];
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
    
//    If we end up using AFIncrementalStore
//
//    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    AFIncrementalStore *incrementalStore = (AFIncrementalStore *)[__persistentStoreCoordinator addPersistentStoreWithType:[SongsIncrementalStore type] configuration:nil URL:nil options:nil error:nil];
//    NSError *error = nil;
//    if (![incrementalStore.backingPersistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    NSLog(@"SQLite URL: %@", [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Songs.sqlite"]);
    
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ScalaOne.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:nil error:&error]) {
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
