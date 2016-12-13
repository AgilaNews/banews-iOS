//
//  DislikeView.m
//  Agilanews
//
//  Created by 张思思 on 16/12/9.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "DislikeView.h"
#import "FilterModel.h"

#define imageWidth  (223 * kScreenWidth / 375.0 + 11)
#define imageHeight 230
#define centreMargin_left  (161 * kScreenWidth / 375.0 + 9)
#define rightMargin_left   (214 * kScreenWidth / 375.0 + 9)

@implementation DislikeView

- (instancetype)initWithRect:(CGRect)rect FilterTags:(NSArray *)filterTags Index:(NSIndexPath *)index
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        self.filterTags = filterTags;
        self.indexPath = index;
        self.reasons = [NSMutableArray array];
        
        BOOL isDown;
        if ((rect.origin.y + 17) / kScreenHeight > .5) {
            isDown = YES;
        } else {
            isDown = NO;
        }
        // 背景对话框
        UIImageView *dislikeBgView = [[UIImageView alloc] init];
        dislikeBgView.userInteractionEnabled = YES;
        dislikeBgView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:dislikeBgView];
        if (kScreenWidth - rect.origin.x > 40) {
            // 箭头出现在中间
            if (isDown) {
                // 出现在上面(箭头向下)
                dislikeBgView.frame = CGRectMake(rect.origin.x + 17 - centreMargin_left, rect.origin.y + 5 - imageHeight, centreMargin_left + 11, imageHeight);
                UIImage *image = [UIImage imageNamed:@"bg_dislike_down"];
                UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 15, 20)];
                dislikeBgView.image = newImage;
                UIGraphicsBeginImageContextWithOptions(dislikeBgView.size, NO, [UIScreen mainScreen].scale);
                [dislikeBgView drawViewHierarchyInRect:dislikeBgView.bounds afterScreenUpdates:YES];
                UIImage *changeImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                dislikeBgView.frame = CGRectMake(rect.origin.x + 17 - centreMargin_left, rect.origin.y + 5 - imageHeight, imageWidth, imageHeight);
                UIImage *finalImage = [changeImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 15, 5)];
                dislikeBgView.image = finalImage;
            } else {
                // 出现在下面(箭头向上)
                dislikeBgView.frame = CGRectMake(rect.origin.x + 17 - centreMargin_left, rect.origin.y + 34 - 5, centreMargin_left + 11, imageHeight);
                UIImage *image = [UIImage imageNamed:@"bg_dislike_up"];
                UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 5, 20)];
                dislikeBgView.image = newImage;
                UIGraphicsBeginImageContextWithOptions(dislikeBgView.size, NO, [UIScreen mainScreen].scale);
                [dislikeBgView drawViewHierarchyInRect:dislikeBgView.bounds afterScreenUpdates:YES];
                UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                dislikeBgView.frame = CGRectMake(rect.origin.x + 17 - centreMargin_left, rect.origin.y + 34 - 5, imageWidth, imageHeight);
                dislikeBgView.image = [finalImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 20, 5, 5)];
            }
        } else {
            // 箭头出现在右边
            if (isDown) {
                // 出现在上面(箭头向下)
                dislikeBgView.frame = CGRectMake(rect.origin.x + 17 - imageWidth + 11, rect.origin.y + 5 - imageHeight, imageWidth, imageHeight);
                UIImage *image = [UIImage imageNamed:@"bg_dislike_down"];
                UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 15, 20)];
                dislikeBgView.image = newImage;
            } else {
                // 出现在下面(箭头向上)
                dislikeBgView.frame = CGRectMake(rect.origin.x + 17 - imageWidth + 11, rect.origin.y + 34 - 5, imageWidth, imageHeight);
                UIImage *image = [UIImage imageNamed:@"bg_dislike_up"];
                UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 5, 20)];
                dislikeBgView.image = newImage;
            }
        }
        
        // 标题
        NSString *titleText = @"Reasons you don't like it";
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:11];
        titleLabel.textColor = kBlackColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = titleText;
        CGSize titleSize = [titleText calculateSize:CGSizeMake(200, 12) font:titleLabel.font];
        titleLabel.frame = CGRectMake((dislikeBgView.width - titleSize.width) *.5, (isDown ? 0 : 10) + 10, titleSize.width, titleSize.height);
        [dislikeBgView addSubview:titleLabel];
        // 横线
        for (int i = 0; i < 2; i++) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 27, .5)];
            lineView.backgroundColor = SSColor_RGB(178);
            if (i == 0) {
                lineView.right = titleLabel.left - 6;
            } else {
                lineView.left = titleLabel.right + 6;
            }
            lineView.center = CGPointMake(lineView.center.x, titleLabel.center.y);
            [dislikeBgView addSubview:lineView];
        }
        
        // 选项
        for (int i = 0; i < 4; i++) {
            if (filterTags.count > i) {
                UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom + 3 + 38 * i, dislikeBgView.width, 38)];;
                buttonView.userInteractionEnabled = YES;
                buttonView.backgroundColor = [UIColor whiteColor];
                
                // 标题
                FilterModel *model = [filterTags objectAtIndex:i];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, dislikeBgView.width - 24 - 24, 38)];
                label.font = [UIFont systemFontOfSize:13];
                label.textColor = SSColor_RGB(102);
                label.text = model.name;
                [buttonView addSubview:label];
                
                // 选中按钮
                UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                imageButton.frame = CGRectMake(dislikeBgView.width - 24, (buttonView.height - 12) * .5, 12, 12);
                imageButton.contentMode = UIViewContentModeScaleAspectFit;
                [imageButton setImage:[UIImage imageNamed:@"icon_choose"] forState:UIControlStateNormal];
                [imageButton setImage:[UIImage imageNamed:@"icon_choose_s"] forState:UIControlStateSelected];
                imageButton.tag = 500 + i;
                [buttonView addSubview:imageButton];
                
                // 点击手势
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonAction:)];
                [buttonView addGestureRecognizer:tap];
                [dislikeBgView addSubview:buttonView];
            }
        }
        
        // 确定按钮
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(5, dislikeBgView.height - 39 - (isDown ? 9 : 0), dislikeBgView.width - 10, 39);
        _okButton.adjustsImageWhenHighlighted = NO;
        [_okButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okButton setTitle:@"OK" forState:UIControlStateNormal];
        [_okButton setTitleColor:kOrangeColor forState:UIControlStateNormal];
        _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [dislikeBgView addSubview:_okButton];
        
        // 按钮上横线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_okButton.left - 5, _okButton.top - 1, _okButton.width + 10, 1)];
        lineView.backgroundColor = SSColor_RGB(235);
        [dislikeBgView addSubview:lineView];
    }
    return self;
}

- (void)buttonAction:(UITapGestureRecognizer *)tap
{
    UIView *button = tap.view;
    for (id object in button.subviews) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *imageButton = object;
            imageButton.selected = !imageButton.selected;
            if (imageButton.selected) {
                [self.reasons addObject:[self.filterTags objectAtIndex:imageButton.tag - 500]];
            } else {
                [self.reasons removeObject:[self.filterTags objectAtIndex:imageButton.tag - 500]];
            }
        }
    }
}

@end
