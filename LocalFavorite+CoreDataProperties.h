//
//  LocalFavorite+CoreDataProperties.h
//  Agilanews
//
//  Created by 张思思 on 16/10/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LocalFavorite+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface LocalFavorite (CoreDataProperties)

+ (NSFetchRequest<LocalFavorite *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *detail_model;
@property (nullable, nonatomic, copy) NSString *collect_time;
@property (nullable, nonatomic, copy) NSString *news_id;
@property (nullable, nonatomic, retain) NSObject *news_model;

@end

NS_ASSUME_NONNULL_END
