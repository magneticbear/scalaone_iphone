//
//  SOEvent.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SOSpeaker, SOUser;

@interface SOEvent : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * textDescription;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * day;
@property (nonatomic, retain) SOUser *favoriteUser;
@property (nonatomic, retain) SOSpeaker *speakers;

@end
