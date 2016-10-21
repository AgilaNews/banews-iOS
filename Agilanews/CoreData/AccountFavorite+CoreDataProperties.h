//
//  AccountFavorite+CoreDataProperties.h
//  Agilanews
//
//  Created by 张思思 on 16/10/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "AccountFavorite+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AccountFavorite (CoreDataProperties)

+ (NSFetchRequest<AccountFavorite *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *collect_id;
@property (nullable, nonatomic, retain) NSObject *detail_model;

@end

NS_ASSUME_NONNULL_END
