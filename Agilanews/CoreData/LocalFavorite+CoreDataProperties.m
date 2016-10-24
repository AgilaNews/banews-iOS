//
//  LocalFavorite+CoreDataProperties.m
//  Agilanews
//
//  Created by 张思思 on 16/10/21.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LocalFavorite+CoreDataProperties.h"

@implementation LocalFavorite (CoreDataProperties)

+ (NSFetchRequest<LocalFavorite *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"LocalFavorite"];
}

@dynamic collect_time;
@dynamic detail_model;
@dynamic news_id;
@dynamic news_model;

@end
