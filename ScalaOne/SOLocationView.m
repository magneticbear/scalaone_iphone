//
//  SOLocationView.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/22/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.

// TODO (Optional): Improve layout logic to allow arbitrary sizes
// TODO (Optional): Set width based on size of name string
// TODO (Optional): Improve the way the disclosure button becomes tappable: enlarging the view isn't ideal
// TODO (Optional): Improve the way large bubble is rendered: expandoffset isn't optimal
// TODO (Optional): Improve performance and re-add shadow

#import "SOLocationView.h"
#import "UIImage+SOAvatar.h"

// CAUTION: Changing these constants may break visuals
#define SOLocationViewStandardWidth     75.0f
#define SOLocationViewStandardHeight    87.0f
#define SOLocationViewExpandOffset      200.0f
#define SOLocationViewVerticalOffset    34.0f
#define SOLocationViewAnimationDuration 0.25f
#define SOLocationViewShadowVisible     FALSE

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
@synthesize avatarImg = _avatarImg;
@synthesize nameLabel = _nameLabel;
@synthesize distanceLabel = _distanceLabel;
@synthesize profileID = _profileID;
@synthesize coordinate = _coordinate;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
{
    if(!(self = [super initWithAnnotation:annotation reuseIdentifier:@"SOLocationView"]))
        return nil;
    
    appDel = (SOAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.canShowCallout = NO;
    self.frame = CGRectMake(0, 0, SOLocationViewStandardWidth, SOLocationViewStandardHeight);
    self.backgroundColor = [UIColor clearColor];
    self.centerOffset = CGPointMake(0, -SOLocationViewVerticalOffset);
    
//    Avatar
    _avatarImg = [[UIImageView alloc] initWithImage:[UIImage avatarWithSource:nil type:SOAvatarTypeUser]];
    _avatarImg.frame = CGRectMake(13, 12, _avatarImg.frame.size.width, _avatarImg.frame.size.height);
    [self addSubview:_avatarImg];
    self.layer.masksToBounds = NO;
    
//    Name Label
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(-34, 20, 170, 20)];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    _nameLabel.shadowOffset = CGSizeMake(0, -1);
    _nameLabel.font = [UIFont boldSystemFontOfSize:17];
    _nameLabel.text = @"Mo Mozafarian";
    _nameLabel.alpha = 0;
    [self addSubview:_nameLabel];
    
//    Distance Label
    _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(-34, 36, 170, 20)];
    _distanceLabel.backgroundColor = [UIColor clearColor];
    _distanceLabel.textColor = [UIColor whiteColor];
    _distanceLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    _distanceLabel.shadowOffset = CGSizeMake(0, -1);
    _distanceLabel.font = [UIFont systemFontOfSize:12];
    _distanceLabel.text = @"200m";
    _distanceLabel.alpha = 0;
    [self addSubview:_distanceLabel];
    
//    Disclosure button
    disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    disclosureButton.frame = CGRectMake(SOLocationViewExpandOffset/2 + self.frame.size.width/2 - 4.0f, 21, disclosureButton.frame.size.width, disclosureButton.frame.size.height);
    
    [disclosureButton addTarget:self action:@selector(didTapDisclosureButton:) forControlEvents:UIControlEventTouchDown];
    disclosureButton.alpha = 0;
    [self addSubview:disclosureButton];
    
    [self setLayerProperties];
    return self;
}

- (void)didTapDisclosureButton:(id)sender {
    [appDel showProfile:_profileID];
}

- (void)didSelectAnnotationViewInMap:(MKMapView*) mapView;
{
//    Center map at annotation point
    [mapView setCenterCoordinate:_coordinate animated:YES];
    [self expand];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView;
{
    [self shrink];
}

- (void)setLayerProperties {
    shapeLayer = [ShadowShapeLayer layer];
    CGPathRef shapeLayerPath = [self newBubbleWithRect:self.bounds andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)];
    shapeLayer.path = shapeLayerPath;
    CGPathRelease(shapeLayerPath);
    
    //Fill Callout Bubble & Add Shadow
    shapeLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:1].CGColor;
    
    strokeAndShadowLayer = [CAShapeLayer layer];
    
    CGPathRef strokeAndShadowLayerPath = [self newBubbleWithRect:self.bounds];
    strokeAndShadowLayer.path = strokeAndShadowLayerPath;
    CGPathRelease(strokeAndShadowLayerPath);
    
    strokeAndShadowLayer.fillColor = [UIColor clearColor].CGColor;
    
    if (SOLocationViewShadowVisible) {
        strokeAndShadowLayer.shadowColor = [UIColor blackColor].CGColor;
        strokeAndShadowLayer.shadowOffset = CGSizeMake (0, self.yShadowOffset);
        strokeAndShadowLayer.shadowRadius = 5.0;
        strokeAndShadowLayer.shadowOpacity = 1.0;
    }
    
    strokeAndShadowLayer.strokeColor = [UIColor colorWithWhite:0.22 alpha:1.0].CGColor;
    strokeAndShadowLayer.lineWidth = 1.0;
    
    CAGradientLayer *bubbleGradient = [CAGradientLayer layer];
    bubbleGradient.frame = CGRectMake(self.bounds.origin.x-SOLocationViewExpandOffset/2, self.bounds.origin.y, SOLocationViewExpandOffset+self.bounds.size.width, self.bounds.size.height-7);
    bubbleGradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:.75].CGColor, (id)[UIColor colorWithWhite:0 alpha:.75].CGColor,(id)[UIColor colorWithWhite:0.13 alpha:.75].CGColor,(id)[UIColor colorWithWhite:0.33 alpha:.75].CGColor, nil];
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

- (CGPathRef)newBubbleWithRect:(CGRect)rect {
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

- (CGPathRef)newBubbleWithRect:(CGRect)rect andOffset:(CGSize)offset {
    CGRect offsetRect = CGRectMake(rect.origin.x+offset.width, rect.origin.y+offset.height, rect.size.width, rect.size.height);
    return [self newBubbleWithRect:offsetRect];
}

- (void)expand {
    self.centerOffset = CGPointMake(SOLocationViewExpandOffset/2, -SOLocationViewVerticalOffset);
    [self animateBubbleWithDirection:SOLocationViewAnimationDirectionGrow];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+SOLocationViewExpandOffset, self.frame.size.height);
    [UIView animateWithDuration:SOLocationViewAnimationDuration/2 delay:SOLocationViewAnimationDuration options:UIViewAnimationCurveEaseInOut animations:^{
        disclosureButton.alpha = 1;
        _nameLabel.alpha = 1;
        _distanceLabel.alpha = 1;
    } completion:^(BOOL finished) {
//        NSLog(@"Animations completed");
    }];
}

- (void)shrink {
    self.centerOffset = CGPointMake(0, -SOLocationViewVerticalOffset);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width-SOLocationViewExpandOffset, self.frame.size.height);
    [UIView animateWithDuration:SOLocationViewAnimationDuration/2 delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        disclosureButton.alpha = 0;
        _nameLabel.alpha = 0;
        _distanceLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [self animateBubbleWithDirection:SOLocationViewAnimationDirectionShrink];
//        NSLog(@"Animations completed");
    }];
}

- (void)animateBubbleWithDirection:(SOLocationViewAnimationDirection)animationDirection {
//    Avatar
    [UIView animateWithDuration:SOLocationViewAnimationDuration animations:^{
        if (animationDirection == SOLocationViewAnimationDirectionGrow) {
            _avatarImg.frame = CGRectMake(_avatarImg.frame.origin.x-SOLocationViewExpandOffset/2, _avatarImg.frame.origin.y, _avatarImg.frame.size.width, _avatarImg.frame.size.height);
        } else if (animationDirection == SOLocationViewAnimationDirectionShrink) {
            _avatarImg.frame = CGRectMake(_avatarImg.frame.origin.x+SOLocationViewExpandOffset/2, _avatarImg.frame.origin.y, _avatarImg.frame.size.width, _avatarImg.frame.size.height);
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
    CGPathRef fromPath = (animationDirection == SOLocationViewAnimationDirectionGrow) ? [self newBubbleWithRect:standardRect] : [self newBubbleWithRect:largeRect];
    animation.fromValue = (__bridge id)fromPath;
    CGPathRelease(fromPath);
    
    CGPathRef toPath = (animationDirection == SOLocationViewAnimationDirectionGrow) ? [self newBubbleWithRect:largeRect] : [self newBubbleWithRect:standardRect];
    animation.toValue = (__bridge id)toPath;
    CGPathRelease(toPath);
    
    [strokeAndShadowLayer addAnimation:animation forKey:animation.keyPath];
    
//    ShapeLayer From/To Values
    fromPath = (animationDirection == SOLocationViewAnimationDirectionGrow) ?
    [self newBubbleWithRect:standardRect andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)] : [self newBubbleWithRect:largeRect andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)];
    animation.fromValue = (__bridge id)fromPath;
    CGPathRelease(fromPath);
    
    toPath = (animationDirection == SOLocationViewAnimationDirectionGrow) ? [self newBubbleWithRect:largeRect andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)] : [self newBubbleWithRect:standardRect andOffset:CGSizeMake(SOLocationViewExpandOffset/2, 0)];
    animation.toValue = (__bridge id)toPath;
    CGPathRelease(toPath);
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
