//
//  SOLocation.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/4/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SOLocation : NSManagedObject

@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * locationID;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * userName;

@end
