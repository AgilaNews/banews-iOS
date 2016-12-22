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
#import "GuideChannelView.h"
#import "CategoriesModel.h"

@interface ChannelViewController ()

@end

@implementation ChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isBackButton = YES;
    [self.backButton setImage:[UIImage imageNamed:@"icon_arrow_left_gary"] forState:UIControlStateNormal];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        NSArray *list = self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([UIDevice currentDevice].systemVersion.integerValue >= 10) {
                UIView *view = (UIView *)obj;
                for (id obj2 in view.subviews) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *image = (UIImageView *)obj2;
                        image.hidden = YES;
                    }
                }
            } else {
                self.navigationController.navigationBar.shadowImage = [UIImage new];
            }
        }
    }
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        UIView *barBgView = self.navigationController.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = [UIColor whiteColor];
                [subview removeAllSubviews];
            }
        }
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor whiteColor]];
    }
    
    // 打点-页面进入-011201
    [Flurry logEvent:@"Channels_Enter"];
#if DEBUG
    [iConsole info:@"Channels_Enter",nil];
#endif

    CGFloat topInset = 0;
    if (iPhone4) {
        topInset = 64 + 25 + 20 + 16 + 20;
    } else {
        topInset = 64 + 25 + 20 + 16 + 32 + 25;
    }
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, topInset, kScreenWidth, kScreenHeight - topInset)];
    bgView.backgroundColor = [UIColor whiteColor];
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
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iPhone4 ? (64 + 10) : (64 + 25), kScreenWidth, 20)];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:19];
    titleLabel.textColor = kBlackColor;
    titleLabel.text = @"Personalize your channel order";
    [_collectionView addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, titleLabel.bottom + 16, kScreenWidth - 40, 32)];
    contentLabel.backgroundColor = [UIColor whiteColor];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.font = [UIFont systemFontOfSize:13];
    contentLabel.textColor = SSColor(102, 102, 102);
    contentLabel.numberOfLines = 0;
    contentLabel.text = @"To reorder the channel，please long press and drag the following tags";
    [_collectionView addSubview:contentLabel];
    
    // 添加OK按钮
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame = CGRectMake(15, _collectionView.height - 45 - 15, kScreenWidth - 30, 45);
    _okButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [_okButton setBackgroundColor:kOrangeColor forState:UIControlStateNormal];
    [_okButton setTitle:@"OK" forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _okButton.layer.cornerRadius = 4;
    _okButton.layer.masksToBounds = YES;
    [_okButton addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    [_collectionView addSubview:_okButton];
    
    if (![DEF_PERSISTENT_GET_OBJECT(SS_GuideCnlKey) isEqualToNumber:@1]) {
        [[UIApplication sharedApplication].keyWindow addSubview:[GuideChannelView sharedInstance]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CleanNewChannel object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    for (CategoriesModel *model in appDelegate.categoriesArray) {
        model.isNew = NO;
    }
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

- (void)dragCellCollectionViewCellEndMoving:(XWDragCellCollectionView *)collectionView
{
    // 打点-长按频道-011204
    [Flurry logEvent:@"Channels_Channel_LongPress"];
#if DEBUG
    [iConsole info:@"Channels_Channel_LongPress",nil];
#endif
}

#pragma mark - 按钮点击事件
- (void)backAction:(UIButton *)button
{
    // 打点-点击返回-011202
    [Flurry logEvent:@"Channels_BackButton_Click"];
#if DEBUG
    [iConsole info:@"Channels_BackButton_Click",nil];
#endif
    [self okAction];
    [super backAction:button];
}

- (void)okAction
{
    if (_dataList.count > 5) {
        for (int i = 0; i < _dataList.count; i++) {
            CategoriesModel *newModel = _dataList[i];
            CategoriesModel *model = _currentList[i];
            if (![newModel.name isEqualToString:model.name]) {
                NSNumber *currentVersion = DEF_PERSISTENT_GET_OBJECT(@"channel_version");
                // 服务器打点-频道顺序调整上报-050101
                NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
                [eventDic setObject:@"050101" forKey:@"id"];
                [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
                if (currentVersion) {
                    [eventDic setObject:currentVersion forKey:@"version"];
                } else {
                    [eventDic setObject:@"" forKey:@"version"];
                }
                NSMutableArray *channels = [NSMutableArray array];
                for (CategoriesModel *model in _dataList) {
                    [channels addObject:model.channelID];
                }
                [eventDic setObject:channels forKey:@"channels"];
                [eventDic setObject:[NetType getNetType] forKey:@"net"];
                if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
                } else {
                    [eventDic setObject:@"" forKey:@"lng"];
                    [eventDic setObject:@"" forKey:@"lat"];
                }
                NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
                if (abflag && abflag.length > 0) {
                    [eventDic setObject:abflag forKey:@"abflag"];
                }
                NSDictionary *sessionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                            DEF_PERSISTENT_GET_OBJECT(@"UUID"), @"id",
                                            [NSArray arrayWithObject:eventDic], @"events",
                                            nil];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
                [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
                    // 打点成功
                } failure:^(NSError *error) {
                    // 打点失败
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate.eventArray addObject:eventDic];
                } isShowHUD:NO];
                
                // 发送频道更改通知
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                appDelegate.categoriesArray = [NSMutableArray arrayWithArray:_dataList];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Categories object:nil];
                break;
            }
        }
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
