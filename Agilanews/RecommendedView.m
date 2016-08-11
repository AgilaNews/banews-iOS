//
//  RecommendedView.m
//  Agilanews
//
//  Created by 张思思 on 16/7/26.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "RecommendedView.h"

@implementation RecommendedView

- (instancetype)initWithFrame:(CGRect)frame titleImage:(UIImage *)image titleText:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kWhiteBgColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, (30 - 13) * .5, 14, 13)];
        imageView.backgroundColor = kWhiteBgColor;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        [self addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 10, 0, kScreenWidth - 70, 30)];
        titleLabel.backgroundColor = kWhiteBgColor;
        titleLabel.textColor = kBlackColor;
        titleLabel.font = [UIFont boldSystemFontOfSize:13];
        titleLabel.text = title;
        [self addSubview:titleLabel];
    }
    return self;
}

@end
