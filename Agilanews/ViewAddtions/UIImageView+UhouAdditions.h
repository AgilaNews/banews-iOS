//
//  UIImageView+UhouAdditions.h
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^tapGestureBlock)(UIImageView *imageView);

@interface UIImageView (UhouAdditions)


- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

+(void)startImageViewRotateAnimation:(UIImageView *)currentImg forKey:(NSString*)key;

+(void)stopImageViewRotateAnimation:(UIImageView *)currentImg forKey:(NSString*)key;

/*
 [imgView addTapGesture:^(UIImageView *imageView) {
 NSLog(@"imageView tap");
 }];
 */

- (void)addTapGesture:(tapGestureBlock)tapBlock;

@end
