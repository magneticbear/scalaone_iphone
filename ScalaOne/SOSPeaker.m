//
//  SOSpeaker.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOSpeaker.h"
#import "SOEvent.h"
#import "SOUser.h"


@implementation SOSpeaker

@dynamic about;
@dynamic email;
@dynamic name;
@dynamic remoteID;
@dynamic title;
@dynamic twitter;
@dynamic url;
@dynamic firstInitial;
@dynamic events;
@dynamic favoriteUser;

- (NSString *) firstInitial {
    [self willAccessValueForKey:@"firstInitial"];
    NSString * initial = [[self name] substringToIndex:1];
    [self didAccessValueForKey:@"firstInitial"];
    return initial;
}

@end
