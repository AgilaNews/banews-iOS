//
//  UITextField+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "UITextField+UhouAdditions.h"

@implementation UITextField (UhouAdditions)

+ (UITextField *)textFieldWithFrame:(CGRect)frame
                        borderStyle:(UITextBorderStyle)borderStyle
                          textColor:(UIColor *)textColor
                    backgroundColor:(UIColor *)backgroundColor
                               font:(UIFont *)font
                       keyboardType:(UIKeyboardType)keyboardType
                                tag:(NSInteger)tag{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle = borderStyle;
    textField.textColor = textColor;
    textField.font = font;
    
    textField.backgroundColor = backgroundColor;
    textField.keyboardType = keyboardType;
    textField.tag = tag;
    
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.leftViewMode = UITextFieldViewModeUnlessEditing;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    return textField;
}

@end
