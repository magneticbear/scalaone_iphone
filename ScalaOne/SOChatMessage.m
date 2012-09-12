//
//  SOChatMessage.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOChatMessage.h"

@implementation SOChatMessage

@synthesize text = _text;
@synthesize senderID = _senderID;
@synthesize channel = _channel;

- (id)initWithText:(NSString *)aText senderID:(NSInteger)aSenderID channel:(NSString *)aChannel {
    self = [super init];
    if (self) {
        _text = aText;
        _senderID = aSenderID;
        _channel = aChannel;
    }
    return self;
}

+ (SOChatMessage *)messageWithText:(NSString *)aText senderID:(NSInteger)aSenderID channel:(NSString *)aChannel {
    return [[self alloc] initWithText:aText senderID:aSenderID channel:aChannel];
}

@end
