//
//  SOCalloutView.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//
//  Based on the work by Jacob Jennings at
//  https://github.com/jacobjennings/JJMapCallout

#import "SOCalloutView.h"


@implementation SOCalloutView
@synthesize mainTitleLabel, leftLabel, rightLabel;


- (id)initWithAnnotation:(id<MKAnnotation>)annotation
{
    if(!(self = [super initWithAnnotation:annotation reuseIdentifier:@"SOCalloutView"]))
        return nil;
    
    [[NSBundle mainBundle] loadNibNamed:@"SOCalloutView" owner:self options:nil];
    
    return self;
}

@end
