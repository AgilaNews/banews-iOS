//
//  InterestCell.m
//  Agilanews
//
//  Created by 张思思 on 16/12/22.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "InterestCell.h"

@implementation InterestCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *labelView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 10, 17)];
        labelView.contentMode = UIViewContentModeScaleAspectFit;
        labelView.image = [UIImage imageNamed:@"icon_lable"];
        [self.contentView addSubview:labelView];
        
        NSString *titleStr = @"Let us know what topics you prefer, GO!";
        CGSize titleSize = [titleStr calculateSize:CGSizeMake(kScreenWidth - 30, 20) font:[UIFont systemFontOfSize:15]];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - titleSize.width - 10 - 11) * .5, (44 - 16) * .5, titleSize.width + 5, 16)];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:titleStr];
        [attributedStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                       NSForegroundColorAttributeName : kBlackColor
                                       } range:NSMakeRange(0, attributedStr.length - 3)];
        [attributedStr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15],
                                       NSForegroundColorAttributeName : kOrangeColor
                                       } range:NSMakeRange(attributedStr.length - 3, 3)];
        titleLabel.attributedText = attributedStr;
        [self.contentView addSubview:titleLabel];
        
        UIImageView *goView = [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.right + 6, (44 - 12) * .5, 11, 12)];
        goView.contentMode = UIViewContentModeScaleAspectFit;
        goView.image = [UIImage imageNamed:@"icon_go"];
        [self.contentView addSubview:goView];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetRGBStrokeColor(context, 1, 206/255.0, 150/255.0, 1.0);
    CGContextSetLineWidth(context, 1.5);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, kScreenWidth, 0);
    CGContextStrokePath(context);
    CGContextSetLineWidth(context, 1);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, self.height - 1);
    CGContextAddLineToPoint(context, kScreenWidth, self.height - 1);
    CGContextStrokePath(context);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
