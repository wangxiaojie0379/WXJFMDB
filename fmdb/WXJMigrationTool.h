//
//  WXJMigrationTool.h
//  fmdb
//
//  Created by wxj on 2018/4/13.
//  Copyright © 2018年 王晓杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDBMigrationManager.h>
@interface WXJMigrationTool : NSObject<FMDBMigrating>

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, assign, readonly) uint64_t version;
- (instancetype)initWithName:(NSString *)name addVersion:(uint64_t)version addandExecuteUpdateStr:(NSString *)updateStr;
- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;
@end
