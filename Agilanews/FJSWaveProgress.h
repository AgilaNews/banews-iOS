//
//  FJSWaveProgress.h
//  FJSWaveAnimation
//
//  Created by 付金诗 on 16/6/29.
//  Copyright © 2016年 www.fujinshi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJSWaveProgress : UIView
@property (nonatomic,assign)CGFloat progress;
@property (nonatomic,assign)CGFloat speed;/**< 波动的速度*/
@property (nonatomic,strong)UIColor * waveColor;
@property (nonatomic,assign)CGFloat waveHeight;

- (void)startWaveAnimation;
- (void)stopWaveAnimation;

@end
