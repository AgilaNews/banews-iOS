//
//  SearchBar.m
//  Agilanews
//
//  Created by 张思思 on 16/12/16.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "SearchBar.h"
#import "SearchViewController.h"

@implementation SearchBar

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = SSColor_RGB(238);
        UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(11, (44 - 28) * .5, kScreenWidth - 22, 28)];
        boxView.backgroundColor = [UIColor whiteColor];
        boxView.layer.cornerRadius = 4;
        boxView.layer.borderColor = SSColor_RGB(217).CGColor;
        boxView.layer.borderWidth = .5;
        [self addSubview:boxView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
        
        NSString *searchString = @"Search news";
        CGSize searchSize = [searchString calculateSize:CGSizeMake(200, 15) font:[UIFont systemFontOfSize:14]];
        UIImageView *searchView = [[UIImageView alloc] initWithFrame:CGRectMake((boxView.width - 13 - 8 - searchSize.width) * .5, (boxView.height - 12) * .5, 13, 12)];
        searchView.contentMode = UIViewContentModeScaleAspectFit;
        searchView.image = [UIImage imageNamed:@"search"];
        [boxView addSubview:searchView];
        
        UILabel *searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(searchView.right + 8, (boxView.height - searchSize.height) * .5, searchSize.width, searchSize.height)];
        searchLabel.font = [UIFont systemFontOfSize:14];
        searchLabel.textColor = kGrayColor;
        searchLabel.text = searchString;
        [boxView addSubview:searchLabel];
    }
    return self;
}

- (void)tapAction
{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    [self.ViewController.navigationController pushViewController:searchVC animated:YES];
}

@end
