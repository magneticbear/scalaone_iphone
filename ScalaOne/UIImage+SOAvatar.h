//
//  UIImage+SOAvatar.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/5/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef enum {
    SOAvatarTypeSmall,
    SOAvatarTypeLarge,
    SOAvatarTypeFavoriteOff,
    SOAvatarTypeFavoriteOn,
} SOAvatarType;

@interface UIImage (SOAvatar)

+ (UIImage*) avatarWithSource:(UIImage*)source type:(SOAvatarType)avatarType;

+ (UIImage*)roundedImage:(UIImage*)image withRadius:(CGFloat)radius scale:(CGFloat)scale;

@end
