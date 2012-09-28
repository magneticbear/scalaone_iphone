//
//  SOUniqueTouchView.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/29/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import <UIKit/UIKit.h>

@class SOUniqueTouchView;

@protocol SOUniqueTouchViewDelegate <NSObject>
@optional

- (UIView *)view:(SOUniqueTouchView *)view hitTest:(CGPoint)point withEvent:(UIEvent *)event hitView:(UIView *)hitView;

@end

@interface SOUniqueTouchView : UIView

@property (nonatomic, weak) id <SOUniqueTouchViewDelegate> viewDelegate;

@end
