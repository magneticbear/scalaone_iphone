//
//  SOChatMessage.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOChatMessage : NSObject

@property (nonatomic, retain) NSString* text;
@property (atomic) NSInteger senderID;
@property (nonatomic, retain) NSDate *dateSent;

- (id)initWithText:(NSString *)aText senderID:(NSInteger)aSenderID date:(NSDate *)aDate;
+ (SOChatMessage *)messageWithText:(NSString *)aText senderID:(NSInteger)aSenderID date:(NSDate *)aDate;

@end
