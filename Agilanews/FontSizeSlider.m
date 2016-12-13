//
//  FontSizeSlider.m
//  Agilanews
//
//  Created by 张思思 on 16/12/13.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FontSizeSlider.h"

@implementation FontSizeSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.minimumValue = 0;
        self.maximumValue = 3;
        self.minimumTrackTintColor = kOrangeColor;
        self.maximumTrackTintColor = [UIColor clearColor];
        self.tintColor = kOrangeColor;
        [self setThumbImage:[UIImage imageNamed:@"ThumbButton"] forState:UIControlStateNormal];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.height - 5) * .5, self.width, 5)];
        imageView.image = [UIImage imageNamed:@"SliderBg"];
        [self addSubview:imageView];
    }
    return self;
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    CGRect rect;
    rect.origin.x = bounds.origin.x;
    rect.origin.y = (bounds.size.height - 6) * .5;
    rect.size.width = bounds.size.width;
    rect.size.height = 6;
    return rect;
}

//- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
//{
//    CGRect thumbRect;
//    thumbRect.origin.x = bounds.origin.x;
//    thumbRect.origin.y = bounds.origin.y;
//    thumbRect.size.width = 50;
//    thumbRect.size.height = 50;
//    return thumbRect;
//}

@end
