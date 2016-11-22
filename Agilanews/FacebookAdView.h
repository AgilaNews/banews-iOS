//
//  FacebookAdView.h
//  Agilanews
//
//  Created by 张思思 on 16/11/22.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookAdView : UIView <FBNativeAdDelegate>

@property (nonatomic, strong) FBNativeAd *nativeAd;
@property (nonatomic, strong) NSNumber *ad_id;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UIImageView *titleImageView;  // 标题图片
@property (nonatomic, strong) UILabel *contentLabel;        // 内容标签
@property (nonatomic, strong) UILabel *sourceLabel;         // 来源
@property (nonatomic, strong) UIButton *learnButton;        // 更多按钮

- (instancetype)initWithNativeAd:(FBNativeAd *)nativeAd AdId:(NSNumber *)ad_id;

@end
