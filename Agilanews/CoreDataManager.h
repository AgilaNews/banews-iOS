//
//  CoreDataManager.h
//  Agilanews
//
//  Created by 张思思 on 16/10/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsDetailModel.h"
#import "NewsModel.h"

@interface CoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataManager *)sharedInstance;

- (void)saveContext;

// AccountFavorite
- (void)addAccountFavoriteWithCollectID:(NSString *)collectID DetailModel:(NewsDetailModel *)model;
- (void)removeAccountFavoriteModelWithCollectIDs:(NSArray *)collectIDs;
- (NewsDetailModel *)searchAccountFavoriteModelWithCollectID:(NSString *)collectID;

// LocalFavorite
- (void)addLocalFavoriteWithNewsID:(NSString *)newsID DetailModel:(NewsDetailModel *)detailModel CollectTime:(NSString *)collectTime NewsModel:(NewsModel *)model;
- (void)removeLocalFavoriteModelWithNewsIDs:(NSArray *)newsIDs;
- (NewsDetailModel *)searchLocalFavoriteModelWithNewsID:(NSString *)newsID;
- (NSArray *)getLocalFavoriteModelList;

@end
