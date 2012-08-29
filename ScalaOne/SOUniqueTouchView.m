//
//  SOUniqueTouchView.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/29/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "SOUniqueTouchView.h"

@implementation SOUniqueTouchView
@synthesize viewDelegate = uniqueTouchViewDelegate;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if ([uniqueTouchViewDelegate respondsToSelector:@selector(view:hitTest:withEvent:hitView:)])
        return [uniqueTouchViewDelegate view:self hitTest:point withEvent:event hitView:hitView];
    else
        return hitView;
}

@end
