//
//  UINavigationBar+Awesome.h
//  LTNavigationBar
//
//  Created by ltebean on 15-2-15.
//  Copyright (c) 2015 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Awesome)
// 设置导航栏背景颜色
- (void)lt_setBackgroundColor:(UIColor *)backgroundColor;
// 设置导航栏标题透明度
- (void)lt_setElementsAlpha:(CGFloat)alpha;
// 设置导航栏偏移位置
- (void)lt_setTranslationY:(CGFloat)translationY;
// 还原设置
- (void)lt_reset;
@end
