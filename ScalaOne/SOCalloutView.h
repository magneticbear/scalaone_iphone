//
//  SOCalloutView.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//
//  Based on the work by Jacob Jennings at
//  https://github.com/jacobjennings/JJMapCallout

#import <Foundation/Foundation.h>
#import "CalloutAnnotationView.h"

@interface SOCalloutView : CalloutAnnotationView {
    
}

@property (nonatomic, strong) IBOutlet UILabel* mainTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* leftLabel;
@property (nonatomic, strong) IBOutlet UILabel* rightLabel;

@end
