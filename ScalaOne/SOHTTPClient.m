//
//  SOHTTPClient.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/23/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOHTTPClient.h"
#import <Bully/Bully.h>

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

#pragma mark - Messages

- (void)getMessagesWithSuccess:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
	[self getPath:@"messages" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}

- (void)postMessage:(SOChatMessage *)message success:(SOHTTPClientSuccess)success failure:(SOHTTPClientFailure)failure {
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							message.text, @"text",
                            [NSNumber numberWithInt:message.senderID], @"senderID",
                            message.dateSent, @"dateSent",
							nil];
	[self postPath:@"messages" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

@end
