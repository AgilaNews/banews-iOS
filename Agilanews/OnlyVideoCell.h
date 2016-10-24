//
//  OnlyVideoCell.h
//  Agilanews
//
//  Created by 张思思 on 16/10/24.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnlyVideoCell : UITableViewCell

@property (nonatomic, strong) UIColor *bgColor;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor;

@end
