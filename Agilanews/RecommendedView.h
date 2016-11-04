//
//  RecommendedView.h
//  Agilanews
//
//  Created by 张思思 on 16/7/26.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendedView : UIView

@property (nonatomic, strong) UILabel *retryLabel;
@property (nonatomic, strong) UIImageView *loadingView;

- (instancetype)initWithFrame:(CGRect)frame titleImage:(UIImage *)image titleText:(NSString *)title HaveLoading:(BOOL)isLoading;
- (void)startAnimation;
- (void)stopAnimation;

@end
