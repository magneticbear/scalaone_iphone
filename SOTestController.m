//
//  SOTestController.m
//  ScalaOne
//
//  Created by Stuart Macgregor on 13-03-25.
//  Copyright (c) 2013 Magnetic Bear Studios. All rights reserved.
//

#import "SOTestController.h"

@implementation SOTestController

+ (void)runTests {
    NSLog(@"hey, I've been called");
    [[SOTestController sharedInstance] startTestingWithCompletionBlock:^{
        // Exit after the tests complete. When running on CI, this lets you check the return value for pass/fail.
        exit([[SOTestController sharedInstance] failureCount]);
    }];
}

- (void)initializeScenarios{
    [self addScenario:[KIFTestScenario scenarioToCheckMyProfile]];
    [self addScenario:[KIFTestScenario scenarioToCheckEvents]];
    [self addScenario:[KIFTestScenario scenarioToCheckDiscussion]];
    [self addScenario:[KIFTestScenario scenarioToCheckFavourites]];
    [self addScenario:[KIFTestScenario scenarioToCheckSpeakers]];
}

@end
