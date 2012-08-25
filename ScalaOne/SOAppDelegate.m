//
//  SOAppDelegate.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/21/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

// TODO: Improve custom back button: currently shifts back button title to infinity and has a very padded image

#import "SOAppDelegate.h"

#import "SOHomeViewController.h"

@implementation SOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[SOHomeViewController alloc] initWithNibName:@"SOHomeViewController" bundle:nil]];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top-bar-repeat"] forBarMetrics:UIBarMetricsDefault];
    
    UIImage *barBtn = [[UIImage imageNamed:@"top-bar-btn-stretch"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    [[UIBarButtonItem appearance] setBackgroundImage:barBtn forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *barBtnDown = [[UIImage imageNamed:@"top-bar-btn-stretch-down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    [[UIBarButtonItem appearance] setBackgroundImage:barBtnDown forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    UIImage *backBtn = [[UIImage imageNamed:@"back-btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBtn forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *backBtnDown = [[UIImage imageNamed:@"back-btn-down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBtnDown forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(HUGE_VALF, HUGE_VALF) forBarMetrics:UIBarMetricsDefault];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
