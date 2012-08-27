//
//  SOAppDelegate.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/21/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SOHomeViewController;

@interface SOAppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *navController;
}

@property (strong, nonatomic) UIWindow *window;

- (void)showProfile:(NSInteger)profileID;

@end
