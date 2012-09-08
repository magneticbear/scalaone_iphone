//
//  SODefines.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SODefines.h"

#pragma mark - Analytics

NSString *const kSOCrashlyticsToken = @"";

#pragma mark - API

#if DEMO
NSString *const kSOAPIHost = @"https://scala1.herokuapp.com/"; // development
#else
NSString *const kSOAPIHost = @"http://108.166.87.233:9000/"; // production
#endif

NSString *const kSOPusherAPIKey = @"";

#pragma mark - Misc

NSString *const kSOKeychainServiceName = @"ScalaOne";

#pragma mark - Notifications

NSString *const kSODidGetMessageNotificationName = @"SODidGetMessageNotification";
