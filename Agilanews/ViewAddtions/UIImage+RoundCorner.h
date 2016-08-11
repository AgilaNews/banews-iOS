//
//  UIImage+RoundCorner.h
//  imageRoundCorner
//
//  Created by Ennnnnn7 on 16/2/22.
//  Copyright © 2016年 uhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RoundCorner)
- (UIImage *)yal_imageWithRoundedCornersAndSize:(CGSize)sizeToFit andCornerRadius:(CGFloat)radius;

- (UIImage*)transformWidth:(CGFloat)width
                    height:(CGFloat)height;
@end
