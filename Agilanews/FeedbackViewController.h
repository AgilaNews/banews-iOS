//
//  FeedbackViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/8/1.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "FeedbackTextView.h"
#import "FeedbackTextField.h"

@interface FeedbackViewController : BaseViewController

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) FeedbackTextView *textView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FeedbackTextField *textField;

@end
