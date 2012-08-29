//
//  SOListHeaderLabel.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/29/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOListHeaderLabel.h"

@implementation SOListHeaderLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
