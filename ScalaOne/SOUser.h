//
//  SOUser.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SOEvent, SOSpeaker;

@interface SOUser : NSManagedObject

@property (nonatomic, retain) NSString * avatar_url;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebook;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSSet *favoriteSpeakers;
@property (nonatomic, retain) NSSet *favoriteEvents;
@end

@interface SOUser (CoreDataGeneratedAccessors)

- (void)addFavoriteSpeakersObject:(SOSpeaker *)value;
- (void)removeFavoriteSpeakersObject:(SOSpeaker *)value;
- (void)addFavoriteSpeakers:(NSSet *)values;
- (void)removeFavoriteSpeakers:(NSSet *)values;

- (void)addFavoriteEventsObject:(SOEvent *)value;
- (void)removeFavoriteEventsObject:(SOEvent *)value;
- (void)addFavoriteEvents:(NSSet *)values;
- (void)removeFavoriteEvents:(NSSet *)values;

@end
