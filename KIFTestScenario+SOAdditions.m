//
//  KIFTestScenario+SOAdditions.m
//  ScalaOne
//
//  Created by Stuart Macgregor on 13-03-25.
//  Copyright (c) 2013 Magnetic Bear Studios. All rights reserved.
//

#import "KIFTestScenario+SOAdditions.h"
#import "KIFTestStep.h"

@implementation KIFTestScenario (SOAdditions)

+ (id)scenarioToCheckEvents {
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Scenario that checks the event view"];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Events"]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Events"]];
    //[scenario addSt]
    return scenario;
}

+ (id)scenarioToCheckSpeakers {
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Scenario that checks the Speakers view"];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Speakers"]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Speakers"]];
    
    return scenario;
}

+ (id)scenarioToCheckFavourites {
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"scenario that checks the favourites view"];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Favorites"]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Favorites"]];
    
    return scenario;
}

+ (id)scenarioToCheckMyProfile {
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Scenario To check the my profile view"];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"My Profile"]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"My Profile"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"Stuart" intoViewWithAccessibilityLabel:@"First"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"stuart@example.com" intoViewWithAccessibilityLabel:@"email@example.com"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"OK"]];
    
    return scenario;
}

+ (id)scenarioToCheckDiscussion {
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Scenario to Check the Discussion view"];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Discuss"]];
    
    return scenario;
}

+(id)scenarioToCheckAbout {
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Scenario To check the about page"];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"About"]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"About TypesafeCon"]];
    return scenario;
}

@end
