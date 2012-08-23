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
@synthesize dateSent = _dateSent;

- (id)initWithText:(NSString *)aText senderID:(NSInteger)aSenderID date:(NSDate *)aDate {
    self = [super init];
    if (self) {
        _text = aText;
        _senderID = aSenderID;
        _dateSent = aDate;
    }
    return self;
}

+ (SOChatMessage *)messageWithText:(NSString *)aText senderID:(NSInteger)aSenderID date:(NSDate *)aDate {
    return [[self alloc] initWithText:aText senderID:aSenderID date:aDate];
}

@end
