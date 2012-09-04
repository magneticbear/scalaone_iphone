//
//  SOHTTPClient.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "AFNetworking.h"
#import "SOChatMessage.h"

typedef void (^SOHTTPClientSuccess)(AFJSONRequestOperation *operation, id responseObject);
typedef void (^SOHTTPClientFailure)(AFJSONRequestOperation *operation, NSError *error);

@class BLYChannel;

@interface SOHTTPClient : AFHTTPClient

+ (SOHTTPClient *)sharedClient;

// Messages
- (void)getMessagesWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;
- (void)postMessage:(SOChatMessage *)message success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;

// Speakers
- (void)getSpeakersWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;

// Events
- (void)getEventsWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure;

@end
