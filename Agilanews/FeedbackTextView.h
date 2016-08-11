//
//  FeedbackTextView.h
//  Agilanews
//
//  Created by 张思思 on 16/8/2.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedbackSubview.h"

@interface FeedbackTextView : UIView

@property (nonatomic, strong) FeedbackSubview *feedbackTextView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *letterNumLabel;
@property (nonatomic, assign) BOOL isInput;

@end
