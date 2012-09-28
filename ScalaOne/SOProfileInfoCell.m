//
//  SOProfileInfoCell.m
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/30/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import "SOProfileInfoCell.h"
#import "UIColor+SOAdditions.h"

#define kCellWidth  282.0f

@interface SOProfileInfoCell ()
@property (nonatomic, retain) UIImageView *bg;
@end

@implementation SOProfileInfoCell
@synthesize headerLabel = _headerLabel;
@synthesize contentTextField = _contentTextField;
@synthesize cellType = _cellType;
@synthesize bg = _bg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect selfFrame = self.frame;
        selfFrame.size.width = kCellWidth;
        self.frame = selfFrame;
        
        // Background Image View
        _bg = [[UIImageView alloc] initWithFrame:self.frame];
        _bg.backgroundColor = [UIColor clearColor];
        [self addSubview:_bg];
        [self setCellType:SOProfileInfoCellTypeMiddle];
        
        // Header Label
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 9, 68, 28)];
        _headerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        _headerLabel.textAlignment = UITextAlignmentRight;
        _headerLabel.textColor = [UIColor lightBlue];
        _headerLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_headerLabel];
        
        // Content Text Field
        _contentTextField = [[UITextField alloc] initWithFrame:CGRectMake(_headerLabel.frame.origin.x+_headerLabel.frame.size.width+11, _headerLabel.frame.origin.y+3, self.frame.size.width-(_headerLabel.frame.origin.x+_headerLabel.frame.size.width+10), _headerLabel.frame.size.height)];
        _contentTextField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16.0f];
        _contentTextField.textColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
        [self addSubview:_contentTextField];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    NSString *highlightedBGString = @"";
    if (highlighted) {
        highlightedBGString = @"-down";
        _headerLabel.textColor = [UIColor whiteColor];
        _contentTextField.textColor = [UIColor whiteColor];
    } else {
        _headerLabel.textColor = [UIColor lightBlue];
        _contentTextField.textColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    }
    
    // Update cell bg on highlight
    switch (_cellType) {
        case SOProfileInfoCellTypeTop:
            _bg.image = [[UIImage imageNamed:[NSString stringWithFormat:@"profile-cell-top%@",highlightedBGString]] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 1, 3)];
            break;
            
        case SOProfileInfoCellTypeMiddle:
            _bg.image = [[UIImage imageNamed:[NSString stringWithFormat:@"profile-cell-middle%@",highlightedBGString]] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 3, 1, 3)];
            break;
            
        case SOProfileInfoCellTypeBottom:
            _bg.image = [[UIImage imageNamed:[NSString stringWithFormat:@"profile-cell-bottom%@",highlightedBGString]] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 3, 3, 3)];
            break;
            
        default:
            break;
    }
}

- (void)setCellType:(SOProfileInfoCellType)aCellType {
    _cellType = aCellType;
    switch (_cellType) {
        case SOProfileInfoCellTypeTop:
            _bg.image = [[UIImage imageNamed:@"profile-cell-top"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 1, 3)];
            break;
            
        case SOProfileInfoCellTypeMiddle:
            _bg.image = [[UIImage imageNamed:@"profile-cell-middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 3, 1, 3)];
            break;
            
        case SOProfileInfoCellTypeBottom:
            _bg.image = [[UIImage imageNamed:@"profile-cell-bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 3, 3, 3)];
            break;
            
        default:
            break;
    }
}

@end
