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
    self.isBackButton = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _dataList = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13"];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((kScreenWidth - 20) / 3.0, (kScreenWidth - 20) / 3.0);
    layout.sectionInset = UIEdgeInsetsMake(210, 10, 10, 10);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[XWDragCellCollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.minimumPressDuration = 0;
    _collectionView.edgeScrollEable = NO;
    _collectionView.shakeWhenMoveing = NO;
    _collectionView.noMoveArray = @[@0];
    [_collectionView registerClass:[ChannelCell class] forCellWithReuseIdentifier:@"ChannelCell"];
    [self.view addSubview:_collectionView];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
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
