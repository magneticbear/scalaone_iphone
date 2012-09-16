//
//  SOMessage.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/15/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SOMessage : NSManagedObject

@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSNumber * messageID;
@property (nonatomic, retain) NSNumber * messageIndex;
@property (nonatomic, retain) NSNumber * senderID;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSDate * sent;
@property (nonatomic, retain) NSString * text;

@end
