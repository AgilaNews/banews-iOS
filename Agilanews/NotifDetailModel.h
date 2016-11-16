//
//  NotifDetailModel.h
//  Agilanews
//
//  Created by 张思思 on 16/11/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsModel.h"
#import "CommentModel.h"

@interface NotifDetailModel : NSObject

@property (nonatomic, strong) NewsModel *related_news;
@property (nonatomic, strong) NSArray *comments;

@end
