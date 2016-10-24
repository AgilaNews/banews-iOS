//
//  CoreDataManager.m
//  Agilanews
//
//  Created by 张思思 on 16/10/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "CoreDataManager.h"
#import "AccountFavorite+CoreDataClass.h"
#import "AccountFavorite+CoreDataProperties.h"
#import "LocalFavorite+CoreDataClass.h"
#import "LocalFavorite+CoreDataProperties.h"

#define kManagedObjectContext [CoreDataManager sharedInstance].managedObjectContext
@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (CoreDataManager *)sharedInstance {
    static CoreDataManager * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CoreDataManager alloc] init];
    });
    return _sharedInstance;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Agila" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Agila.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - AccountFavorite
- (void)addAccountFavoriteWithCollectID:(NSString *)collectID DetailModel:(NewsDetailModel *)model
{
    AccountFavorite *accountFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"AccountFavorite" inManagedObjectContext:kManagedObjectContext];
    accountFavorite.collect_id = collectID;
    accountFavorite.detail_model = model;
    
    [[CoreDataManager sharedInstance] saveContext]; //插入 保存
}
- (void)removeAccountFavoriteModelWithCollectIDs:(NSArray *)collectIDs
{
    BOOL isChange = NO;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AccountFavorite"
                                              inManagedObjectContext:kManagedObjectContext];
    [request setEntity:entity];
    //使用谓词NSPredicate  添加查询条件 相当于sqlite中的sql语句
    NSMutableArray *predicateArray = [NSMutableArray array];
    for (NSString *collectID in collectIDs) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"collect_id = %@",collectID];
        [predicateArray addObject:predicate];
    }
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *objectResults = [kManagedObjectContext executeFetchRequest:request error:&error];
    if (objectResults && objectResults.count > 0 ) {
        isChange = YES;
        for (NSManagedObject *object in objectResults) {
            [kManagedObjectContext deleteObject:object];
        }
    }
    if (isChange) {
        [[CoreDataManager sharedInstance] saveContext]; //删除之后 保存
    }
}
- (NewsDetailModel *)searchAccountFavoriteModelWithCollectID:(NSString *)collectID
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AccountFavorite"
                                              inManagedObjectContext:kManagedObjectContext];
    [request setEntity:entity];
    //使用谓词NSPredicate  添加查询条件 相当于sqlite中的sql语句
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"collect_id = %@", collectID];
    [request setPredicate:predicate];
    //设置 获得数组的 排序方式(可根据需要 设置添加)
//    NSSortDescriptor *byCourseName = [NSSortDescriptor sortDescriptorWithKey:@"courseName"ascending:YES];
//    NSSortDescriptor *byCourseId = [NSSortDescriptor sortDescriptorWithKey:@"courseId" ascending:YES];
//    NSArray *sortDescriptors = [NSMutableArray arrayWithObjects:byCourseName,byCourseId, nil];
//    [request setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *objectResults = [kManagedObjectContext executeFetchRequest:request error:&error];
    if (objectResults.count > 0) {
        NSManagedObject *manageObj = objectResults.firstObject;
        return [manageObj valueForKey:@"detail_model"];
    }
    return nil;
}

#pragma mark - LocalFavorite
- (void)addLocalFavoriteWithNewsID:(NSString *)newsID DetailModel:(NewsDetailModel *)detailModel CollectTime:(NSString *)collectTime NewsModel:(NewsModel *)model
{
    LocalFavorite *localFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"LocalFavorite" inManagedObjectContext:kManagedObjectContext];
    localFavorite.news_id = newsID;
    localFavorite.detail_model = detailModel;
    localFavorite.collect_time = collectTime;
    localFavorite.news_model = model;
    [[CoreDataManager sharedInstance] saveContext]; //插入 保存
}
- (void)removeLocalFavoriteModelWithNewsIDs:(NSArray *)newsIDs
{
    BOOL isChange = NO;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalFavorite"
                                              inManagedObjectContext:kManagedObjectContext];
    [request setEntity:entity];
    //使用谓词NSPredicate  添加查询条件 相当于sqlite中的sql语句
    NSMutableArray *predicateArray = [NSMutableArray array];
    for (NSString *newsID in newsIDs) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"news_id = %@",newsID];
        [predicateArray addObject:predicate];
    }
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *objectResults = [kManagedObjectContext executeFetchRequest:request error:&error];
    if (objectResults && objectResults.count > 0 ) {
        isChange = YES;
        for (NSManagedObject *object in objectResults) {
            [kManagedObjectContext deleteObject:object];
        }
    }
    if (isChange) {
        [[CoreDataManager sharedInstance] saveContext]; //删除之后 保存
    }
}
- (NSArray *)getLocalFavoriteModelList
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalFavorite"
                                              inManagedObjectContext:kManagedObjectContext];
    [request setEntity:entity];
    // 降序排列
    NSSortDescriptor *byCollectTime = [NSSortDescriptor sortDescriptorWithKey:@"collect_time" ascending:NO];
    NSArray *sortDescriptors = [NSMutableArray arrayWithObjects:byCollectTime, nil];
    [request setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *objectResults = [kManagedObjectContext executeFetchRequest:request error:&error];
    if (objectResults.count > 0) {
        return objectResults;
    }
    return nil;
}
- (NewsDetailModel *)searchLocalFavoriteModelWithNewsID:(NSString *)newsID
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalFavorite"
                                              inManagedObjectContext:kManagedObjectContext];
    [request setEntity:entity];
    //使用谓词NSPredicate  添加查询条件 相当于sqlite中的sql语句
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"news_id = %@", newsID];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *objectResults = [kManagedObjectContext executeFetchRequest:request error:&error];
    if (objectResults.count > 0) {
        NSManagedObject *manageObj = objectResults.firstObject;
        return [manageObj valueForKey:@"detail_model"];
    }
    return nil;
}


@end
