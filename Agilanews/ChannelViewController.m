//
//  ChannelViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/9/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "ChannelViewController.h"
#import "ChannelCell.h"

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
    CGFloat topInset = 64 + 25 + 20 + 16 + 32 + 25;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, topInset, kScreenWidth, kScreenHeight - topInset)];
    bgView.backgroundColor = SSColor(246, 246, 246);
    [self.view addSubview:bgView];
    _dataList = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13"];
    
    CGFloat itemWidth = (kScreenWidth - 18) / 3.0;
    CGFloat itemHeight = 46;
    CGFloat spacing = 9;
    for (int i = 0; i < _dataList.count; i++) {
        UIView *cellBgView = [[UIView alloc] initWithFrame:CGRectMake(9 + 1 + spacing * .5 + i % 3 * itemWidth, 25 + 1 + spacing * .5 + i / 3 * itemHeight , itemWidth - spacing - 2, itemHeight - spacing - 2)];
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
    layout.sectionInset = UIEdgeInsetsMake(topInset + 25, 9, 9, 9);
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

#pragma mark - XWDragCellCollectionViewDelegate
- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView
{
    return _dataList;
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray
{
    _dataList = newDataArray;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChannelCell" forIndexPath:indexPath];
    cell.title = _dataList[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    XWCellModel *model = _data[indexPath.section][indexPath.item];
//    NSLog(@"%@", model.title);
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
