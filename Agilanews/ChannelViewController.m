//
//  ChannelViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/9/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "ChannelViewController.h"
#import "ChannelCell.h"
#import "AppDelegate.h"

@interface ChannelViewController ()

@end

@implementation ChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = @"Channels";
    self.view.backgroundColor = SSColor(235, 235, 235);
    self.isBackButton = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 添加导航栏右侧按钮
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame = CGRectMake(0, 0, 60, 40);
    _okButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [_okButton setTitle:@"OK" forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.4] forState:UIControlStateDisabled];
    [_okButton addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc]initWithCustomView:_okButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -20;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, okItem];
    _okButton.enabled = NO;

    
    CGFloat topInset = 64 + 25 + 20 + 16 + 32 + 25;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, topInset, kScreenWidth, kScreenHeight - topInset)];
    bgView.backgroundColor = SSColor(246, 246, 246);
    [self.view addSubview:bgView];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _dataList = appDelegate.categoriesArray;
    _currentList = [_dataList copy];
    
    CGFloat itemWidth = (kScreenWidth - 30) / 3.0;
    CGFloat itemHeight = 46;
    CGFloat spacing = 12;
    for (int i = 0; i < _dataList.count; i++) {
        UIView *cellBgView = [[UIView alloc] initWithFrame:CGRectMake(15 + 1 + spacing * .5 + i % 3 * itemWidth, 25 + 1 + spacing * .5 + i / 3 * itemHeight , itemWidth - spacing - 2, itemHeight - spacing - 2)];
        [bgView addSubview:cellBgView];
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.bounds = CGRectMake(0, 0, cellBgView.width, cellBgView.height);
        borderLayer.position = CGPointMake(CGRectGetMidX(cellBgView.bounds), CGRectGetMidY(cellBgView.bounds));
        borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:CGRectGetWidth(borderLayer.bounds)/2].CGPath;
        borderLayer.lineWidth = 1;
        borderLayer.lineDashPattern = @[@6, @5];
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.strokeColor = SSColor(204, 204, 204).CGColor;
        [cellBgView.layer addSublayer:borderLayer];
    }

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.sectionInset = UIEdgeInsetsMake(topInset + 25, 15, 15, 15);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[XWDragCellCollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.minimumPressDuration = 0;
    _collectionView.edgeScrollEable = NO;
    _collectionView.shakeWhenMoveing = NO;
    _collectionView.noMoveArray = @[@0];
    [_collectionView registerClass:[ChannelCell class] forCellWithReuseIdentifier:@"ChannelCell"];
    [self.view addSubview:_collectionView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64 + 25, kScreenWidth, 20)];
    titleLabel.backgroundColor = SSColor(235, 235, 235);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:19];
    titleLabel.textColor = kBlackColor;
    titleLabel.text = @"Personalize your channel order";
    [_collectionView addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, titleLabel.bottom + 16, kScreenWidth - 40, 32)];
    contentLabel.backgroundColor = SSColor(235, 235, 235);
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.font = [UIFont systemFontOfSize:13];
    contentLabel.textColor = SSColor(102, 102, 102);
    contentLabel.numberOfLines = 0;
    contentLabel.text = @"To reorder the channel，please long press and drag the following tags";
    [_collectionView addSubview:contentLabel];
}

- (void)dealloc
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    for (CategoriesModel *model in appDelegate.categoriesArray) {
        model.isNew = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CleanNewChannel object:nil];
}

#pragma mark - XWDragCellCollectionViewDelegate
- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView
{
    return _dataList;
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray
{
    _dataList = newDataArray;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < _dataList.count; i++) {
            CategoriesModel *newModel = _dataList[i];
            CategoriesModel *model = _currentList[i];
            if (![newModel.name isEqualToString:model.name]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _okButton.enabled = YES;
                    return;
                });
            }
        }
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChannelCell" forIndexPath:indexPath];
    cell.model = _dataList[indexPath.item];
    [cell setNeedsLayout];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    XWCellModel *model = _data[indexPath.section][indexPath.item];
//    NSLog(@"%@", model.title);
}

#pragma mark - 按钮点击事件
- (void)backAction:(UIButton *)button
{
    [self okAction];
    [super backAction:button];
}

- (void)okAction
{
    if (_dataList.count > 5) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.categoriesArray = [NSMutableArray arrayWithArray:_dataList];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Categories object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
