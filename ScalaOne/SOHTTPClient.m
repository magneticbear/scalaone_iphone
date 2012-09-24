//
//  SOHTTPClient.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOHTTPClient.h"

@implementation SOHTTPClient {
	dispatch_queue_t _callbackQueue;
	NSString *_clientID;
	NSString *_clientSecret;
}

#pragma mark - Singleton

+ (SOHTTPClient *)sharedClient {
	static SOHTTPClient *sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedClient = [[self alloc] init];
	});
	return sharedClient;
}

#pragma mark - NSObject

- (id)init {
    NSURL *base = [NSURL URLWithString:kSOAPIHost];
	if ((self = [super initWithBaseURL:base])) {
        
		[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
		[self setDefaultHeader:@"Accept" value:@"application/json"];
        
		_callbackQueue = dispatch_queue_create("com.magneticbear.scalaone.network-callback-queue", 0);
	}
	return self;
}

- (void)dealloc {
	SODispatchRelease(_callbackQueue);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - AFHTTPClient

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	return request;
}

- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
	operation.successCallbackQueue = _callbackQueue;
	operation.failureCallbackQueue = _callbackQueue;
	[super enqueueHTTPRequestOperation:operation];
}

#pragma mark - Users

- (void)getUserWithID:(NSInteger)userID success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
    NSDictionary *params = @{@"token" : kSOAPIToken};
    [self getPath:[NSString stringWithFormat:@"users/%d",userID] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

- (void)createUser:(SOUser *)user success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
    NSDictionary *params = [self userParametersWithUser:user];
    
	[self postPath:@"users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

- (void)updateUser:(SOUser *)user success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
    NSDictionary *params = [self userParametersWithUser:user];
    
	[self putPath:[NSString stringWithFormat:@"users/%d",user.remoteID.integerValue] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

- (void)postImage:(UIImage *)image forUserID:(NSInteger)userID success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"users/%d/image?token=%@",userID,kSOAPIToken] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"picture" fileName:@"picture.jpg" mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
    }];
    
    [operation start];
}

#pragma mark - Messages

- (void)getMessagesAtPath:(NSString *)path withSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
    NSDictionary *params = @{@"token" : kSOAPIToken};
	[self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

- (void)postMessage:(SOChatMessage *)message toPath:(NSString *)path success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
    NSDictionary *params = @{@"content" : message.text,
    @"senderId" : [NSNumber numberWithInt:message.senderID],
    @"token" : kSOAPIToken};
    
	[self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

#pragma mark - Speakers

- (void)getSpeakersWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
	[self getPath:@"speakers" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

#pragma mark - Events

- (void)getEventsWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
	[self getPath:@"events" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

#pragma mark - Locations

- (void)getLocationsWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
    NSDictionary *params = @{@"location" : @1,
    @"token" : kSOAPIToken};
    
    [self getPath:@"users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

- (void)updateLocationForUser:(SOUser *)user success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
    NSDictionary *params = @{@"latitude" : [NSString stringWithFormat:@"%.5f",user.latitude.floatValue],
    @"longitude" : [NSString stringWithFormat:@"%.5f",user.longitude.floatValue],
    @"token" : kSOAPIToken};
    
	[self putPath:[NSString stringWithFormat:@"users/%d/location",user.remoteID.integerValue] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

#pragma mark - Utitilies

- (NSDictionary *)userParametersWithUser:(SOUser *)user {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (user.firstName.length) [params addEntriesFromDictionary:@{@"firstName" : user.firstName}];
    if (user.lastName.length) [params addEntriesFromDictionary:@{@"lastName" : user.lastName}];
    if (user.twitter.length) [params addEntriesFromDictionary:@{@"twitter" : user.twitter}];
    if (user.facebook.length) [params addEntriesFromDictionary:@{@"facebook" : user.facebook}];
    if (user.phone.length) [params addEntriesFromDictionary:@{@"phone" : user.phone}];
    if (user.email.length) [params addEntriesFromDictionary:@{@"email" : user.email}];
    if (user.website.length) [params addEntriesFromDictionary:@{@"website" : user.website}];
    if (user.latitude.floatValue != 0) [params addEntriesFromDictionary:@{@"latitude" : [NSString stringWithFormat:@"%.5f",user.latitude.floatValue]}];
    if (user.longitude.floatValue != 0) [params addEntriesFromDictionary:@{@"longitude" : [NSString stringWithFormat:@"%.5f",user.longitude.floatValue]}];
    [params addEntriesFromDictionary:@{@"token" : kSOAPIToken}];
    
    return [NSDictionary dictionaryWithDictionary:params];
}

@end
