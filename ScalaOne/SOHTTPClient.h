//
//  SOHTTPClient.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "AFNetworking.h"
#import "SOChatMessage.h"
#import "SOUser.h"

typedef void (^SOHTTPClientSuccess)(AFJSONRequestOperation *operation, id responseObject);
typedef void (^SOHTTPClientFailure)(AFJSONRequestOperation *operation, NSError *error);

@interface SOHTTPClient : AFHTTPClient

+ (SOHTTPClient *)sharedClient;

// Users
- (void)getUserWithID:(NSInteger)userID success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;
- (void)createUser:(SOUser *)user success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;
- (void)updateUser:(SOUser *)user success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;
- (void)postImage:(UIImage *)image forUserID:(NSInteger)userID success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;

// Messages
- (void)getMessagesAtPath:(NSString *)path withSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;
- (void)postMessage:(SOChatMessage *)message toPath:(NSString *)path success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;

// Speakers
- (void)getSpeakersWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;

// Events
- (void)getEventsWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;

// Locations
- (void)getLocationsWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;
- (void)updateLocationForUser:(SOUser *)user success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;

@end
