//
//  ChannelViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/9/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"

@interface ChannelViewController : BaseViewController<XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate>

@property (nonatomic, strong) XWDragCellCollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataList;

@end
