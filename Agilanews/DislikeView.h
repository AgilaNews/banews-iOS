//
//  DislikeView.h
//  Agilanews
//
//  Created by 张思思 on 16/12/9.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DislikeView : UIView

- (instancetype)initWithRect:(CGRect)rect FilterTags:(NSArray *)filterTags Index:(NSIndexPath *)index;

@property (nonatomic, strong) NSArray *filterTags;
@property (nonatomic, strong) NSMutableArray *reasons;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIButton *okButton;

@end
