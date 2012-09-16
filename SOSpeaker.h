//
//  SOSpeaker.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/15/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SOSpeaker : NSManagedObject

@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstInitial;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * favorite;

@end
