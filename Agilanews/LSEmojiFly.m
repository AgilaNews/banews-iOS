//
//  LSEmojiFly.m
//  EmojiFly
//
//  Created by ZhangPeng on 16/4/11.
//  Copyright © 2016年 Rising. All rights reserved.
//

#import "LSEmojiFly.h"

@interface LSEmojiFly()

/** 定时器 */
@property (strong, nonatomic) CADisplayLink *displayLink;
/** 图片 */
@property (strong, nonatomic) UIImage *image;
/** 显示图片的视图 */
@property (strong, nonatomic) UIView *view;

@end

@implementation LSEmojiFly

+ (LSEmojiFly *)emojiFly{
    return [[LSEmojiFly alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handlerAction:)];
        self.displayLink.frameInterval = 15;
    }
    return self;
}

- (void)startFlyWithEmojiImage:(UIImage *)image onView:(UIView *)view{
    self.image = image;
    self.view = view;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)endFly{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)handlerAction:(CADisplayLink *)displayLink{
    NSInteger count = arc4random() % 4;
    for (int i = 0; i < count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = self.image;
        imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
        
        CGSize viewSize = self.view.bounds.size;
        CGFloat x = arc4random_uniform(viewSize.width);
        CGFloat y = -imageView.frame.size.height;
        imageView.center = CGPointMake(x, y);
        [self.view addSubview:imageView];
        
        [UIView animateWithDuration:4 animations:^{
            CGFloat toX = arc4random_uniform(viewSize.width);
            CGFloat toY = viewSize.height + imageView.frame.size.height * 0.5;
            imageView.center = CGPointMake(toX, toY);
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
        }];
    }
}

@end
