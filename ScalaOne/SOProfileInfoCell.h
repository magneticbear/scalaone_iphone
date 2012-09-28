//
//  SOProfileInfoCell.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 8/30/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import <UIKit/UIKit.h>

typedef enum {
    SOProfileInfoCellTypeTop,
    SOProfileInfoCellTypeMiddle,
    SOProfileInfoCellTypeBottom,
} SOProfileInfoCellType;

@interface SOProfileInfoCell : UITableViewCell {
    UILabel *headerLabel;
    UITextField *contentTextField;
    SOProfileInfoCellType cellType;
}

@property (nonatomic, retain) UILabel *headerLabel;
@property (nonatomic, retain) UITextField *contentTextField;
@property (nonatomic) SOProfileInfoCellType cellType;

@end
