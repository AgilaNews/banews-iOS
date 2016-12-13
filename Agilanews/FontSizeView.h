//
//  FontSizeView.h
//  Agilanews
//
//  Created by 张思思 on 16/12/13.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontSizeSlider.h"

@interface FontSizeView : UIView

@property (nonatomic, strong) FontSizeSlider *slider;
@property (nonatomic, strong) NSNumber *sliderValue;
@property (nonatomic, strong) UIButton *cancelButton;

@end
