//
//  NSString+SOAdditions.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/12/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import <Foundation/Foundation.h>

@interface NSString (SOAdditions)

// Channel names
+ (NSString *)generalChannelName;
+ (NSString *)eventChannelNameWithEventID:(NSInteger)eventID;
+ (NSString *)privateChannelNameWithSenderID:(NSInteger)senderID targetID:(NSInteger)targetID;

// Chatroom urls
+ (NSString *)generalChatURL;
+ (NSString *)eventChatURLWithEventID:(NSInteger)eventID;
+ (NSString *)privateChatURLWithSenderID:(NSInteger)senderID targetID:(NSInteger)targetID;

@end
