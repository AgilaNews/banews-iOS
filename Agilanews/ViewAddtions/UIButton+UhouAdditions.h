//
//  UIButton+UhouAdditions.h
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (UhouAdditions)

+ (UIButton *)buttonWithFrame:(CGRect)frame
                        title:(NSString *)title
                   titleColor:(UIColor *)titleColor
          titleHighlightColor:(UIColor *)titleHighlightColor
                    titleFont:(UIFont *)titleFont
                        image:(UIImage *)imageName
                  tappedImage:(UIImage *)tappedImageName
                       target:(id)target
                       action:(SEL)selector
                          tag:(NSInteger)tag;

/**
 *  设置背景色
 *
 *  @param backgroundColor 颜色
 *  @param state           
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;


@end
