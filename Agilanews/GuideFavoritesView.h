//
//  GuideFavoritesView.h
//  Agilanews
//
//  Created by 张思思 on 16/8/5.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideFavoritesView : UIView

@property (nonatomic, strong) UIImageView *favoritesView;

+ (instancetype)sharedInstance;

@end
