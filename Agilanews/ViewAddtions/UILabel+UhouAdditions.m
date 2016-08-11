//
//  UILabel+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "UILabel+UhouAdditions.h"

@implementation UILabel (UhouAdditions)

+ (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                  textColor:(UIColor *)textColor
                       font:(UIFont *)font
                        tag:(NSInteger)tag
                  hasShadow:(BOOL)hasShadow{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    if( hasShadow ){
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(1,1);
    }
    label.textAlignment = NSTextAlignmentLeft;
    label.font = font;
    label.tag = tag;
    
    return label;
}
+ (UILabel *)labelForNavigationBarWithTitle:(NSString*)title
                                  textColor:(UIColor *)textColor
                                       font:(UIFont *)font
                                  hasShadow:(BOOL)hasShadow{
    UILabel *titleLbl = [UILabel labelWithFrame:CGRectMake(60, 0, 200, 44)
                                           text:title
                                      textColor:textColor
                                           font:font
                                            tag:0
                                      hasShadow:hasShadow];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    return titleLbl;
}
- (void)contentSafeString:(NSString*)text
{
    NSString * nullString1 = @"(null)";
    NSString * nullString2 = @"null";
    self.text = [text stringByReplacingOccurrencesOfString:nullString1 withString:@""];
    self.text = [text stringByReplacingOccurrencesOfString:nullString2 withString:@""];
}





@end
