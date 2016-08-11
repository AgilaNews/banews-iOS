//
//  CommentTextView.h
//  Agilanews
//
//  Created by 张思思 on 16/7/27.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTextView : UIView

@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) BOOL isInput;
@property (nonatomic, strong) NSString *news_id;

@end
