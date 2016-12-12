//
//  DislikeView.m
//  Agilanews
//
//  Created by 张思思 on 16/12/9.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "DislikeView.h"

#define imageWidth  (223 * kScreenWidth / 375.0 + 11)
#define imageHeight 228 * kScreenWidth / 375.0
#define centreMargin_left  (161 * kScreenWidth / 375.0 + 9)
#define rightMargin_left   (214 * kScreenWidth / 375.0 + 9)

@implementation DislikeView

- (instancetype)initWithRect:(CGRect)rect
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        
        // 背景对话框
        UIImageView *dislikeBgView = [[UIImageView alloc] init];
        dislikeBgView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:dislikeBgView];
        if (kScreenWidth - rect.origin.x > 40) {
            // 箭头出现在中间
            if ((rect.origin.y + 17) / kScreenHeight > .5) {
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
            if ((rect.origin.y + 17) / kScreenHeight > .5) {
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
    }
    return self;
}

@end
