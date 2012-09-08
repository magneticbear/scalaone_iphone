//
//  SOShareKitConfigurator.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/8/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOShareKitConfigurator.h"

@implementation SOShareKitConfigurator
/*
 App Description
 ---------------
 These values are used by any service that shows 'shared from XYZ'
 */
- (NSString*)appName {
	return @"Scala1 for iPhone";
}

- (NSString*)appURL {
	return @"https://github.com/magneticbear/scalaone_iphone/";
}

- (NSString*)facebookAppId {
	return kSOFacebookAppId;
}

@end
