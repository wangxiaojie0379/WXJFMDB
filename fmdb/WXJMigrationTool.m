//
//  WXJMigrationTool.m
//  fmdb
//
//  Created by wxj on 2018/4/13.
//  Copyright © 2018年 王晓杰. All rights reserved.
//

#import "WXJMigrationTool.h"

@interface WXJMigrationTool()
@property(nonatomic, strong) NSString *myName;
@property(nonatomic, assign) uint64_t myVersion;
@property(nonatomic, strong) NSString *updateStr;
@end
@implementation WXJMigrationTool

- (instancetype)initWithName:(NSString *)name addVersion:(uint64_t)version addandExecuteUpdateStr:(NSString *)updateStr{
    self = [super init];
    if (self) {
        _myName = name;
        _myVersion = version;
        _updateStr = updateStr;
    }
    return self;
}
- (NSString *)name{
    return _myName;
}
- (uint64_t)version{
    return _myVersion;
}
- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error{
    BOOL isUpdate = [database executeUpdate:_updateStr];
    NSLog(isUpdate ? @"update sucess" : @"update failure");
    return isUpdate;
}





@end


























