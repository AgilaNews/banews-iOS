//
//  CAEmitterLayerView.h
//  Agilanews
//
//  Created by 张思思 on 16/12/5.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAEmitterLayerView : UIView

// setter，getter方法
- (void)setEmitterLayer:(CAEmitterLayer *)layer;
- (CAEmitterLayer *)emitterLayer;

// 显示出当前view
- (void)show;
// 隐藏
- (void)hide;

@end
