//
//  SOSpeaker.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/15/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import "SOSpeaker.h"


@implementation SOSpeaker

@dynamic about;
@dynamic email;
@dynamic firstInitial;
@dynamic name;
@dynamic remoteID;
@dynamic title;
@dynamic twitter;
@dynamic url;
@dynamic favorite;

- (NSString *) firstInitial {
    [self willAccessValueForKey:@"firstInitial"];
    NSString * initial = [[self name] substringToIndex:1];
    [self didAccessValueForKey:@"firstInitial"];
    return initial;
}

@end
