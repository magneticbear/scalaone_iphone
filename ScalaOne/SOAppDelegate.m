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
    
//    Navigation Bar Title
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:242.0/255.0 green:250.0/255.0 blue:252.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [UIColor colorWithRed:10.0/255.0 green:137.0/255.0 blue:179.0/255.0 alpha:1.0],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0],
      UITextAttributeFont,
      nil]];
    
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

- (void)showProfile:(NSInteger)profileID {
    SOProfileViewController *profileVC = [[SOProfileViewController alloc] initWithNibName:@"SOProfileViewController" bundle:nil];
    [navController pushViewController:profileVC animated:YES];
}

@end
