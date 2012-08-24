//
//  SOLocationView.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.

#import "SOLocationView.h"

#define CalloutMapAnnotationViewBottomShadowBufferSize 6.0f
#define CalloutMapAnnotationViewContentHeightBuffer 8.0f
#define CalloutMapAnnotationViewHeightAboveParent 30.0f
#define CalloutMapAnnotationViewInset 4.0f

@interface ShadowShapeLayer : CAShapeLayer
@end

@implementation ShadowShapeLayer
-(void) drawInContext:(CGContextRef)context {
    CGContextSaveGState( context );
    CGContextSetShadow( context , CGSizeMake( 0 , 6 ) , 6 );
    [super drawInContext:context];
    CGContextRestoreGState( context );
}
@end

@implementation SOLocationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
{
    if(!(self = [super initWithAnnotation:annotation reuseIdentifier:@"SOLocationView"]))
        return nil;
    
    self.canShowCallout = NO;
    self.frame = CGRectMake(0, 0, 100, 100);
    self.backgroundColor = [UIColor clearColor];
    self.centerOffset = CGPointMake(50, 100);
    self.clipsToBounds = NO;
    return self;
}

- (void)didSelectAnnotationViewInMap:(MKMapView*) mapView;
{
    NSLog(@"didSelectAnnotationViewInMap");
    [self animateBubbleWithDirection:SOLocationViewAnimationDirectionGrow];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView;
{
    NSLog(@"didDeselectAnnotationViewInMap");
    [self animateBubbleWithDirection:SOLocationViewAnimationDirectionShrink];
}

- (void)layoutSubviews {
    [self setLayerProperties];
}

- (void)setLayerProperties {
    shapeLayer = [ShadowShapeLayer layer];
    shapeLayer.path = [self bubbleWithRect:self.bounds];
    
    //Fill Callout Bubble & Add Shadow
    shapeLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:1].CGColor;
    
    strokeAndShadowLayer = [CAShapeLayer layer];
    strokeAndShadowLayer.path = shapeLayer.path;
    strokeAndShadowLayer.fillColor = [UIColor clearColor].CGColor;
    strokeAndShadowLayer.shadowColor = [UIColor blackColor].CGColor;
    strokeAndShadowLayer.shadowOffset = CGSizeMake (0, self.yShadowOffset);
    strokeAndShadowLayer.shadowRadius = 5.0;
    strokeAndShadowLayer.shadowOpacity = 1.0;
    strokeAndShadowLayer.strokeColor = [UIColor colorWithWhite:0.22 alpha:1.0].CGColor;
    strokeAndShadowLayer.lineWidth = 1.0;
    
    CAGradientLayer *bubbleGradient = [CAGradientLayer layer];
    bubbleGradient.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width+30, self.bounds.size.height-22);
    bubbleGradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:.5].CGColor, (id)[UIColor colorWithWhite:0 alpha:.5].CGColor,(id)[UIColor colorWithWhite:0.13 alpha:.5].CGColor,(id)[UIColor colorWithWhite:0.33 alpha:.5].CGColor, nil];
    bubbleGradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0.53],[NSNumber numberWithFloat:.54],[NSNumber numberWithFloat:1], nil];
    bubbleGradient.startPoint = CGPointMake(0.0f, 1.0f);
    bubbleGradient.endPoint = CGPointMake(0.0f, 0.0f);
    BOOL gradient = TRUE;
    if (gradient) {
        bubbleGradient.mask = shapeLayer;
        [strokeAndShadowLayer addSublayer:bubbleGradient];
        [self.layer addSublayer:strokeAndShadowLayer];
    } else {
        [self.layer addSublayer:bubbleGradient];
        [self.layer addSublayer:shapeLayer];
    }
}

- (CGPathRef)bubbleWithRect:(CGRect)rect {
    CGFloat xOffset = 15;
    CGFloat stroke = 1.0;
	CGFloat radius = 7.0;
	CGMutablePathRef path = CGPathCreateMutable();
	CGFloat parentX = [self relativeParentXPosition]+xOffset;
	
	//Determine Size
	rect.size.width -= stroke + 14;
	rect.size.height -= stroke + 14 + CalloutMapAnnotationViewHeightAboveParent;
	rect.origin.x += stroke / 2.0 + 7 + xOffset;
	rect.origin.y += stroke / 2.0 + 7;
    
	//Create Path For Callout Bubble
	CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
	CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
	CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
	CGPathAddLineToPoint(path, NULL, parentX - 14, rect.origin.y + rect.size.height);
	CGPathAddLineToPoint(path, NULL, parentX, rect.origin.y + rect.size.height + 14);
	CGPathAddLineToPoint(path, NULL, parentX + 14, rect.origin.y + rect.size.height);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
	CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
	CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
	CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
	CGPathCloseSubpath(path);
    return path;
}

- (void)animateBubbleWithDirection:(SOLocationViewAnimationDirection)animationDirection {
    CGPathRef largePath = [self bubbleWithRect:CGRectMake(self.bounds.origin.x-20, self.bounds.origin.y, self.bounds.size.width+40, self.bounds.size.height)];
    CGPathRef standardPath = [self bubbleWithRect:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height)];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    animation.fromValue = (animationDirection == SOLocationViewAnimationDirectionGrow) ?
        (__bridge id)standardPath : (__bridge id)largePath;
    
    animation.toValue = (animationDirection == SOLocationViewAnimationDirectionGrow) ?
        (__bridge id)largePath : (__bridge id)standardPath;
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 0.5;
    [shapeLayer addAnimation:animation forKey:animation.keyPath];
    [strokeAndShadowLayer addAnimation:animation forKey:animation.keyPath];
}

- (CGFloat)yShadowOffset {
	if (!_yShadowOffset) {
		float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
		if (osVersion >= 3.2) {
			_yShadowOffset = 3;
		} else {
			_yShadowOffset = -3;
		}
	}
	return _yShadowOffset;
}

- (CGFloat)relativeParentXPosition {
	return self.bounds.size.width / 2;
}

@end
