//
//  UIImage+SOAvatar.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/5/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef enum {
    SOAvatarFavoriteTypeDefault,
    SOAvatarFavoriteTypeOff,
    SOAvatarFavoriteTypeOn,
} SOAvatarFavoriteType;

@interface UIImage (SOAvatar)

+ (UIImage*) avatarWithSource:(UIImage*)source favorite:(SOAvatarFavoriteType)favorite;

+ (UIImage*)roundedImage:(UIImage*)image withRadius:(CGFloat)radius scale:(CGFloat)scale;

@end
