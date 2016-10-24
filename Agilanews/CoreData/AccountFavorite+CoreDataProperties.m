//
//  AccountFavorite+CoreDataProperties.m
//  Agilanews
//
//  Created by 张思思 on 16/10/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "AccountFavorite+CoreDataProperties.h"

@implementation AccountFavorite (CoreDataProperties)

+ (NSFetchRequest<AccountFavorite *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"AccountFavorite"];
}

@dynamic collect_id;
@dynamic detail_model;

@end
