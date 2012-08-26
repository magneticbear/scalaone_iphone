//
//  SOLocationView.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.

// TODO: Make appropriate data accessible (img, name, distance, ID, etc.)
// TODO: Fix tapping disclosure button also passes touch underneath

// TODO (Optional): Reposition map to display full expanded view on tap
// TODO (Optional): Improve layout logic to allow arbitrary sizes
// TODO (Optional): Set width based on size of name string
// TODO (Optional): Improve the way the disclosure button becomes tappable: enlarging the view isn't ideal
// TODO (Optional): Improve the way large bubble is rendered: expandoffset isn't optimal

#import "SOLocationView.h"

// CAUTION: Changing these constants may break visuals
#define SOLocationViewStandardWidth 75.0f
#define SOLocationViewStandardHeight 87.0f
#define SOLocationViewExpandOffset 200.0f
#define SOLocationViewVerticalOffset 34.0f
#define SOLocationViewAnimationDuration 0.33f

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
    self.frame = CGRectMake(0, 0, SOLocationViewStandardWidth, SOLocationViewStandardHeight);
    self.backgroundColor = [UIColor clearColor];
    self.centerOffset = CGPointMake(0, -SOLocationViewVerticalOffset);
    
//    Avatar
    avatarImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_avatar_mo"]];
    avatarImg.frame = CGRectMake(13, 12, avatarImg.frame.size.width, avatarImg.frame.size.height);
    [self addSubview:avatarImg];
    self.layer.masksToBounds = NO;
    
//    Name Label
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(-34, 20, 170, 20)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    nameLabel.shadowOffset = CGSizeMake(0, -1);
    nameLabel.font = [UIFont boldSystemFontOfSize:17];
    nameLabel.text = @"Mo Mozafarian";
    nameLabel.alpha = 0;
    [self addSubview:nameLabel];
    
//    Distance Label
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(-34, 36, 170, 20)];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.textColor = [UIColor whiteColor];
    distanceLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    distanceLabel.shadowOffset = CGSizeMake(0, -1);
    distanceLabel.font = [UIFont systemFontOfSize:12];
    distanceLabel.text = @"200m";
    distanceLabel.alpha = 0;
    [self addSubview:distanceLabel];
    
//    Disclosure button
    disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    disclosureButton.frame = CGRectMake(SOLocationViewExpandOffset/2 + self.frame.size.width/2 - 4.0f, 21, disclosureButton.frame.size.width, disclosureButton.frame.size.height);
    
    [disclosureButton addTarget:self action:@selector(didTapDisclosureButton:) forControlEvents:UIControlEventTouchUpInside];
    disclosureButton.alpha = 0;
    [self addSubview:disclosureButton];
    
    [self setLayerProperties];
    return self;
}

- (void)didTapDisclosureButton:(id)sender {
    NSLog(@"didTapDisclosureButton");
}

- (void)didSelectAnnotationViewInMap:(MKMapView*) mapView;
{
    NSLog(@"didSelectAnnotationViewInMap");
    [self expand];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView;
{
    NSLog(@"didDeselectAnnotationViewInMap");
    [self shrink];
}

- (void)setLayerProperties {
    shapeLayer = [ShadowShapeLayer layer];
    shapeLayer.path = [self bubbleWithRect:self.bounds andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)];
    
    //Fill Callout Bubble & Add Shadow
    shapeLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:1].CGColor;
    
    strokeAndShadowLayer = [CAShapeLayer layer];
    strokeAndShadowLayer.path = [self bubbleWithRect:self.bounds];
    strokeAndShadowLayer.fillColor = [UIColor clearColor].CGColor;
    strokeAndShadowLayer.shadowColor = [UIColor blackColor].CGColor;
    strokeAndShadowLayer.shadowOffset = CGSizeMake (0, self.yShadowOffset);
    strokeAndShadowLayer.shadowRadius = 5.0;
    strokeAndShadowLayer.shadowOpacity = 1.0;
    strokeAndShadowLayer.strokeColor = [UIColor colorWithWhite:0.22 alpha:1.0].CGColor;
    strokeAndShadowLayer.lineWidth = 1.0;
    
    CAGradientLayer *bubbleGradient = [CAGradientLayer layer];
    bubbleGradient.frame = CGRectMake(self.bounds.origin.x-SOLocationViewExpandOffset/2, self.bounds.origin.y, SOLocationViewExpandOffset+self.bounds.size.width, self.bounds.size.height-7);
    bubbleGradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:.5].CGColor, (id)[UIColor colorWithWhite:0 alpha:.5].CGColor,(id)[UIColor colorWithWhite:0.13 alpha:.5].CGColor,(id)[UIColor colorWithWhite:0.33 alpha:.5].CGColor, nil];
    bubbleGradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0.53],[NSNumber numberWithFloat:.54],[NSNumber numberWithFloat:1], nil];
    bubbleGradient.startPoint = CGPointMake(0.0f, 1.0f);
    bubbleGradient.endPoint = CGPointMake(0.0f, 0.0f);
    bubbleGradient.mask = shapeLayer;
    
    shapeLayer.masksToBounds = NO;
    bubbleGradient.masksToBounds = NO;
    strokeAndShadowLayer.masksToBounds = NO;
    
    [strokeAndShadowLayer addSublayer:bubbleGradient];
    [self.layer insertSublayer:strokeAndShadowLayer atIndex:0];
}

- (CGPathRef)bubbleWithRect:(CGRect)rect {
    CGFloat stroke = 1.0;
	CGFloat radius = 7.0;
	CGMutablePathRef path = CGPathCreateMutable();
	CGFloat parentX = rect.origin.x + rect.size.width/2;
	
	//Determine Size
	rect.size.width -= stroke + 14;
	rect.size.height -= stroke + 29;
	rect.origin.x += stroke / 2.0 + 7;
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

- (CGPathRef)bubbleWithRect:(CGRect)rect andOffset:(CGSize)offset {
    CGRect offsetRect = CGRectMake(rect.origin.x+offset.width, rect.origin.y+offset.height, rect.size.width, rect.size.height);
    return [self bubbleWithRect:offsetRect];
}

- (void)expand {
    self.centerOffset = CGPointMake(SOLocationViewExpandOffset/2, -SOLocationViewVerticalOffset);
    [self animateBubbleWithDirection:SOLocationViewAnimationDirectionGrow];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+SOLocationViewExpandOffset, self.frame.size.height);
    [UIView animateWithDuration:SOLocationViewAnimationDuration/2 delay:SOLocationViewAnimationDuration options:UIViewAnimationCurveEaseInOut animations:^{
        disclosureButton.alpha = 1;
        nameLabel.alpha = 1;
        distanceLabel.alpha = 1;
    } completion:^(BOOL finished) {
        NSLog(@"Animations completed");
    }];
}

- (void)shrink {
    self.centerOffset = CGPointMake(0, -SOLocationViewVerticalOffset);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width-SOLocationViewExpandOffset, self.frame.size.height);
    [UIView animateWithDuration:SOLocationViewAnimationDuration/2 delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        disclosureButton.alpha = 0;
        nameLabel.alpha = 0;
        distanceLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [self animateBubbleWithDirection:SOLocationViewAnimationDirectionShrink];
        NSLog(@"Animations completed");
    }];
}

- (void)animateBubbleWithDirection:(SOLocationViewAnimationDirection)animationDirection {
//    Avatar
    [UIView animateWithDuration:SOLocationViewAnimationDuration animations:^{
        if (animationDirection == SOLocationViewAnimationDirectionGrow) {
            avatarImg.frame = CGRectMake(avatarImg.frame.origin.x-SOLocationViewExpandOffset/2, avatarImg.frame.origin.y, avatarImg.frame.size.width, avatarImg.frame.size.height);
        } else if (animationDirection == SOLocationViewAnimationDirectionShrink) {
            avatarImg.frame = CGRectMake(avatarImg.frame.origin.x+SOLocationViewExpandOffset/2, avatarImg.frame.origin.y, avatarImg.frame.size.width, avatarImg.frame.size.height);
        }
    }];
    
//    Bubble
    CGRect largeRect = CGRectMake(self.bounds.origin.x-SOLocationViewExpandOffset/2, self.bounds.origin.y, self.bounds.size.width+SOLocationViewExpandOffset, self.bounds.size.height);
    CGRect standardRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = SOLocationViewAnimationDuration;
    
//    Stroke & Shadow From/To Values
    animation.fromValue = (animationDirection == SOLocationViewAnimationDirectionGrow) ?
    (__bridge id)[self bubbleWithRect:standardRect] : (__bridge id)[self bubbleWithRect:largeRect];
    
    animation.toValue = (animationDirection == SOLocationViewAnimationDirectionGrow) ?
    (__bridge id)[self bubbleWithRect:largeRect] : (__bridge id)[self bubbleWithRect:standardRect];
    [strokeAndShadowLayer addAnimation:animation forKey:animation.keyPath];
    
//    ShapeLayer From/To Values
    animation.fromValue = (animationDirection == SOLocationViewAnimationDirectionGrow) ?
    (__bridge id)[self bubbleWithRect:standardRect andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)] : (__bridge id)[self bubbleWithRect:largeRect andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)];
    
    animation.toValue = (animationDirection == SOLocationViewAnimationDirectionGrow) ?
    (__bridge id)[self bubbleWithRect:largeRect andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)] : (__bridge id)[self bubbleWithRect:standardRect andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)];
    [shapeLayer addAnimation:animation forKey:animation.keyPath];
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

@end
