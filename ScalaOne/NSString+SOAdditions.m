//
//  NSString+SOAdditions.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/12/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import "NSString+SOAdditions.h"

@implementation NSString (SOAdditions)

+ (NSString *)generalChannelName {
    return @"general";
}

+ (NSString *)eventChannelNameWithEventID:(NSInteger)eventID {
    return [self stringWithFormat:@"event-%d", eventID];
}

+ (NSString *)privateChannelNameWithSenderID:(NSInteger)senderID targetID:(NSInteger)targetID {
    NSInteger lowID = MIN(senderID, targetID);
    NSInteger highID = MAX(senderID, targetID);
    return [self stringWithFormat:@"private_%d_%d", lowID, highID];
}

+ (NSString *)generalChatURL {
    return @"messages/general";
}

+ (NSString *)eventChatURLWithEventID:(NSInteger)eventID {
    return [self stringWithFormat:@"messages/event/%d", eventID];
}

+ (NSString *)privateChatURLWithSenderID:(NSInteger)senderID targetID:(NSInteger)targetID {
    return [self stringWithFormat:@"messages/private/%d/%d", senderID, targetID];
}

@end
