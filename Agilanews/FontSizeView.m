//
//  FontSizeView.m
//  Agilanews
//
//  Created by 张思思 on 16/12/13.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FontSizeView.h"
#import "SinglePicCell.h"
#import "NewsModel.h"
#import "ImageModel.h"

@implementation FontSizeView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 12 + 68 + 12 + 108 + 45)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        // 预览cell
        SinglePicCell *cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" bgColor:[UIColor whiteColor]];
        cell.width = kScreenWidth;
        cell.height = 12 + 68 + 12;
        [self addSubview:cell];
        NewsModel *model = [[NewsModel alloc] init];
        model.title = @"AgilaBuzz are always trying to provide best reading service for you!";
        model.source = @"AgilaBuzz";
        model.public_time = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
        ImageModel *imageModel = [[ImageModel alloc] init];
        imageModel.pattern = @"http://s1.agilanews.today/app/agila-settings.jpg?t={w}x{h}";
        model.imgs = @[imageModel];
        cell.model = model;
        [cell setNeedsLayout];
        
        // 横线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(cell.left + 11, cell.bottom, cell.width - 22, 1)];
        lineView.backgroundColor = SSColor_RGB(235);
        [self addSubview:lineView];
        
        // 选择器
        self.slider = [[FontSizeSlider alloc] initWithFrame:CGRectMake((38 + 60) * .5, cell.bottom + (108 - 20) * .5, kScreenWidth - 38 - 60, 20)];
        [self addSubview:self.slider];
        [self.slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.slider addGestureRecognizer:tap];
        
        NSNumber *fontSize = DEF_PERSISTENT_GET_OBJECT(SS_FontSize);
        switch (fontSize.integerValue) {
            case 0:
                [self.slider setValue:1.0];
                self.sliderValue = @1;
                break;
            case 1:
                [self.slider setValue:3.0];
                self.sliderValue = @3;
                break;
            case 2:
                [self.slider setValue:2.0];
                self.sliderValue = @2;
                break;
            case 3:
                [self.slider setValue:0.0];
                self.sliderValue = @0;
                break;
            default:
                break;
        }
        
        // 文字标注
        for (int i = 0; i < 2; i++) {
            NSString *fontText = @"A";
            UILabel *label = nil;
            if (i == 0) {
                CGSize labelSize = [fontText calculateSize:CGSizeMake(25, 25) font:[UIFont systemFontOfSize:14]];
                label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
                label.font = [UIFont systemFontOfSize:14];
                label.right = self.slider.left - 10;
            } else {
                CGSize labelSize = [fontText calculateSize:CGSizeMake(25, 25) font:[UIFont systemFontOfSize:20]];
                label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
                label.font = [UIFont systemFontOfSize:20];
                label.left = self.slider.right + 10;
            }
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = kGrayColor;
            label.text = fontText;
            label.center = CGPointMake(label.center.x, self.slider.center.y);
            [self addSubview:label];
        }
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(0, self.height - 45, kScreenWidth, 45);
        self.cancelButton.adjustsImageWhenHighlighted = NO;
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.cancelButton setBackgroundColor:SSColor_RGB(246) forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:SSColor_RGB(178) forState:UIControlStateNormal];
        [self addSubview:self.cancelButton];
    }
    return self;
}

// 点击手势
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    CGPoint p = [tap locationInView:tap.view];
    float tempFloat = p.x / tap.view.width * 3;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"0"];
    NSString *tempStr = [formatter stringFromNumber:[NSNumber numberWithFloat:tempFloat]];
    [self.slider setValue:tempStr.floatValue];
    self.sliderValue = [NSNumber numberWithFloat:tempStr.integerValue];
}

// 滑杆变化
- (void)sliderChange:(FontSizeSlider *)slider
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"0"];
    NSString *tempStr = [formatter stringFromNumber:[NSNumber numberWithFloat:slider.value]];
    [slider setValue:tempStr.floatValue];
    self.sliderValue = [NSNumber numberWithFloat:tempStr.integerValue];
}

// 字体变化
- (void)setSliderValue:(NSNumber *)sliderValue
{
    if (![_sliderValue isEqualToNumber:sliderValue]) {
        _sliderValue = sliderValue;
        
        switch (sliderValue.integerValue) {
            case 0:
            {
                // 打点-选择字体大小-010902
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Small", @"text_size",
                                               nil];
                [Flurry logEvent:@"Set_FontSize_Set_Click" withParameters:articleParams];
#if DEBUG
                [iConsole info:[NSString stringWithFormat:@"Set_FontSize_Set_Click:%@",articleParams],nil];
#endif
                DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @3);
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
                break;
            }
            case 1:
            {
                // 打点-选择字体大小-010902
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Normal", @"text_size",
                                               nil];
                [Flurry logEvent:@"Set_FontSize_Set_Click" withParameters:articleParams];
#if DEBUG
                [iConsole info:[NSString stringWithFormat:@"Set_FontSize_Set_Click:%@",articleParams],nil];
#endif
                DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @0);
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
                break;
            }
            case 2:
            {
                // 打点-选择字体大小-010902
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Large", @"text_size",
                                               nil];
                [Flurry logEvent:@"Set_FontSize_Set_Click" withParameters:articleParams];
#if DEBUG
                [iConsole info:[NSString stringWithFormat:@"Set_FontSize_Set_Click:%@",articleParams],nil];
#endif
                DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @2);
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
                break;
            }
            case 3:
            {
                // 打点-选择字体大小-010902
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Extra Large", @"text_size",
                                               nil];
                [Flurry logEvent:@"Set_FontSize_Set_Click" withParameters:articleParams];
#if DEBUG
                [iConsole info:[NSString stringWithFormat:@"Set_FontSize_Set_Click:%@",articleParams],nil];
#endif
                DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @1);
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
                break;
            }
            default:
                break;
        }
    }
}



@end
