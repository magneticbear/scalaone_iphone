//
//  UIColor+SOAdditions.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/21/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "UIColor+SOAdditions.h"

@implementation UIColor (SOAdditions)

+ (UIColor *)lightBlue {
    return [self colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
}

+ (UIColor *)lightGray {
    return [self colorWithWhite:0.15f alpha:1.0f];
}

+ (UIColor *)darkBlue {
    return [self colorWithRed:0.059 green:0.486 blue:0.612 alpha:1];
}

+ (UIColor *)mediumGray {
    return [self colorWithWhite:0.3f alpha:1.0f];
}

@end
