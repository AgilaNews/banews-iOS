//
//  UIButton+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "UIButton+UhouAdditions.h"

@implementation UIButton (UhouAdditions)

+ (UIButton *)buttonWithFrame:(CGRect)frame
                        title:(NSString *)title
                   titleColor:(UIColor *)titleColor
          titleHighlightColor:(UIColor *)titleHighlightColor
                    titleFont:(UIFont *)titleFont
                        image:(UIImage *)image
                  tappedImage:(UIImage *)tappedImage
                       target:(id)target
                       action:(SEL)selector
                          tag:(NSInteger)tag{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    if( title!=nil && title.length>0 ){
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        [button setTitleColor:titleHighlightColor forState:UIControlStateHighlighted];
        button.titleLabel.font = titleFont;
    }
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    if( image){
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
    if( tappedImage){
        [button setBackgroundImage:tappedImage forState:UIControlStateHighlighted];
    }
    
    return button;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[UIButton imageWithColor:backgroundColor] forState:state];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
