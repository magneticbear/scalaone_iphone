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

#pragma mark - Tokens
#if public
#warning All constants here must be valid for the app to work
#else

#define kSOCrashlyticsToken             @""

#define kSOAPIHost                      @""

#define kSOAPIToken                     @""

#define kSOPusherAPIKey                 @""

#define kSOFacebookAppId                @""

#endif

#pragma mark - Strings

#define kSONoTwitterAccountsTitle       @"No Twitter Accounts"
#define kSONoTwitterAccountsMessage     @"You have not yet linked a Twitter account with this iPhone. Open iPhone Settings to link one."
#define kSOTwitterHashtag               @"#scala1"
#define kSOTwitterServiceType           @"com.apple.social.twitter"

#define kSONoFacebookAccountTitle       @"No Facebook Account"
#define kSONoFacebookAccountMessage     @"You have not yet linked a Facebook account with this iPhone. Open iPhone Settings to link one."

#pragma mark - URL schemes

#define kSOGoogleChromeScheme           @"googlechrome"
#define kSOGoogleChromeSchemeSecure     @"googlechromes"
#define kSOHTTPScheme                   @"http"
#define kSOHTTPSchemeSecure             @"https"
#define kSOScala1Scheme                 @"scala1"

#pragma mark - Screen Titles

#define kSOScreenTitleHome              @"Scala1"
#define kSOScreenTitleEvents            @"Events"
#define kSOScreenTitleSpeakers          @"Speakers"
#define kSOScreenTitleFavorites         @"Favorites"
#define kSOScreenTitleMyProfile         @"My Profile"
#define kSOScreenTitleChatGeneral       @"Discussion"
#define kSOScreenTitleChatPrivate       @"Private chat"
#define kSOScreenTitleChatEvent         @"Event chat"
#define kSOScreenTitleMap               @"Find an enthusiast"
#define kSOScreenTitleAbout             @"About Scala1"
#define kSOScreenTitlePlayground        @"Playground"

#pragma mark - Image URL Formats

#define kSOImageURLFormatForUser        @"%@assets/img/user/%d.jpg"
#define kSOImageURLFormatForSpeaker     @"%@assets/img/profile/%d.jpg"

#endif
