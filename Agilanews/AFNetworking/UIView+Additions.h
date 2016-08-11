//
//  UIView+UhouAdditions.h
//  Uhou_Framework
//
//  Created by 张思思 on 16/7/12.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);


@interface UIView (UhouAdditions)


@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

/**
 *  移动到某个点
 *
 *  @param delta 具体点
 */
- (void) moveBy: (CGPoint) delta;
/**
 *  缩小放大
 *
 *  @param scaleFactor 放大缩小倍数
 */
- (void) scaleBy: (CGFloat) scaleFactor;
/**
 *  给定大小缩放
 *
 *  @param aSize 缩放的具体大小
 */
- (void) fitInSize: (CGSize) aSize;
/**
 *  获取试图控制器
 *
 *  @return 返回控制器
 */
- (UIViewController *) ViewController;


/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat frameleft;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat frametop;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat frameright;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat framebottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat framewidth;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat frameheight;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat framecenterX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat framecenterY;

/**
 * Return the x coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenX;

/**
 * Return the y coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenY;

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint frameorigin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize framesize;

/**
 * Return the width in portrait or the height in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationWidth;

/**
 * Return the height in portrait or the width in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationHeight;

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (UIView*)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (UIView*)ancestorOrSelfWithClass:(Class)cls;

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;

/**
 * Calculates the offset of this view from another view in screen coordinates.
 *
 * otherView should be a parent view of this view.
 */
- (CGPoint)offsetFromView:(UIView*)otherView;




/**
 *  设置边框
 *
 *  @param borderWidth 边框宽度
 *  @param borderColor 边框颜色
 */
-(void)setBorderWidth:(NSInteger)borderWidth andBorderColor:(UIColor *)borderColor;


#pragma mark 设置灰边框
- (void)loadViewGrayBorderBorderWidth:(NSInteger )borderWidth;
#pragma mark 设置蓝边框
- (void)loadViewBlueBorderBorderWidth:(NSInteger )borderWidth;

/**
 *  设置为圆形   ---->>>>>>前提是view的宽高相等
 */
-(void) makeCircleView;

/**
 *  设置圆角
 *
 *  @param radius
 */
-(void)makeCornerRadius:(CGFloat)radius;
@end
