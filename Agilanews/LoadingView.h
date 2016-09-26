//
//  LoadingView.h
//  Agilanews
//
//  Created by 张思思 on 16/9/23.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (nonatomic, strong) UIImageView *loading;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) NSString *percent;

- (void)startAnimation;
- (void)stopAnimation;

@end
