//
//  SODefines.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef SODEFINES
#define SODEFINES

// SODispatchRelease
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
#define SODispatchRelease(queue)
#else
#define SODispatchRelease(queue) dispatch_release(queue)
#endif

#pragma mark - API

extern NSString *const kSOAPIScheme;
extern NSString *const kSOAPIHost;
extern NSString *const kSOPusherAPIKey;

#pragma mark - Misc

extern NSString *const kSOKeychainServiceName;

#pragma mark - Notifications

extern NSString *const kSODidGetMessageNotificationName;

#endif
