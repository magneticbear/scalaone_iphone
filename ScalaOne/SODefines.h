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

extern NSString *const kSOCrashlyticsToken;

extern NSString *const kSOAPIHost;

extern NSString *const kSOPusherAPIKey;

extern NSString *const kSOFacebookAppId;

#pragma mark - Strings

#define kSONoTwitterAccountsTitle       @"No Twitter Accounts"
#define kSONoTwitterAccountsMessage     @"You have not yet linked a Twitter account with this iPhone. Open iPhone Settings to link one."

#define kSONoFacebookAccountTitle       @"No Facebook Account"
#define kSONoFacebookAccountMessage     @"You have not yet linked a Facebook account with this iPhone. Open iPhone Settings to link one."

#endif
