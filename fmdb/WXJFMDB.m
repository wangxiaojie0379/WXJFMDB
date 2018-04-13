//
//  WXJFMDB.m
//  fmdb
//
//  Created by 王晓杰 on 2018/4/9.
//  Copyright © 2018年 王晓杰. All rights reserved.
//

#import "WXJFMDB.h"
#import <UIKit/UIKit.h>
#import "WXJMigrationTool.h"
#import <FMDBMigrationManager.h>

#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //int long integer ...
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //data

@interface WXJFMDB()
@property(nonatomic, strong) FMDatabase *db;
@end

@implementation WXJFMDB

+ (instancetype)shareInstance{
    return [[[self class] alloc] init];
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [self creatSqliteL:[self achieveDataBasePath]];
    }
    return self;
}
//获取文件路径
- (NSString *)achieveDataBasePath{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"itemDb.sqlite"];
    return filePath;
}
//字典转data
- (NSData *)dictTransformData:(NSDictionary *)dataDict{
    NSData *data= [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
    return data;
}
//创建数据库
- (void)creatSqliteL:(NSString *)path{
    if ([path isEqualToString:@""]) {
        NSLog(@"sqlite path length == 0");
        return;
    }
    NSLog(@"%@", path);
    _db = [FMDatabase databaseWithPath:path];
    BOOL isDbOpen = [_db open];
    if (isDbOpen) {
//        NSString *name = [NSString stringWithFormat:@"%@.sqlite", name];
        BOOL isCreatTable = [_db executeUpdate:@"create table if not exists t_wxjdataDict(id integer primary key,dataDict BLOB not null,idStr text not null);"];
        NSLog(isCreatTable ? @"creat table sucess" : @"creat table faliure");
    }else{
        NSLog(@"sqlite open failure");
    }
}
//插入数据
- (BOOL)insertData:(NSDictionary *)dataDict idStr:(NSString *)idStr{
    BOOL isInsert = [_db executeUpdateWithFormat:@"insert into t_wxjdataDict(dataDict,idStr) values(%@,%@)",[self dictTransformData:dataDict],idStr];
    NSLog(isInsert ? @"insert sucess" : @"insert  faliure");
    return isInsert;
}
//更新数据
- (BOOL)updataData:(NSDictionary *)dataDict idStr:(NSString *)idStr{
    BOOL isUpdate = [_db executeUpdateWithFormat:@"update t_wxjdataDict set dataDict=%@,idStr = %@",[self dictTransformData:dataDict],idStr];
    NSLog(isUpdate ? @"update sucess" : @"update  faliure");
    return isUpdate;
}
//删除某条数据
- (BOOL)deleteData:(NSString *)idStr{
    BOOL isDelete = [_db executeUpdateWithFormat:@"delete from t_wxjdataDict where idStr = %@",idStr];
    NSLog(isDelete ? @"delete sucess" : @"delete  faliure");
    return isDelete;
}
//删除全部
- (BOOL)deleteAllData{
    BOOL res = [_db executeUpdate:@"DELETE FROM t_wxjdataDict"];
    NSLog(res?@"clear all sucess":@"clear all faliure");
    return res;
}
//查找全部数据
- (NSMutableArray *)queryAllData{
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_wxjdataDict"];
    NSMutableArray *list = [NSMutableArray array];
    while (set.next) {
        NSLog(@"%@", [set objectForColumn:@"dataDict"]);
        // 获得当前所指向的数据
        NSData *dataStr = [set objectForColumn:@"dataDict"];
        NSData *data = [NSData dataWithData:dataStr];
        NSDictionary *dictionary =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [list addObject:dictionary];
    }
    return list;
}
//查找某个数据
- (NSMutableArray *)queryAPieceData:(NSString *)idStr{
    
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_wxjdataDict where idStr = ?", idStr];
    NSMutableArray *list = [NSMutableArray array];
    while (set.next) {
        NSLog(@"%@", [set objectForColumn:@"dataDict"]);
        // 获得当前所指向的数据
        NSData *dataStr = [set objectForColumn:@"dataDict"];
        NSData *data = [NSData dataWithData:dataStr];
        NSDictionary *dictionary =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [list addObject:dictionary];
    }
    return list;
}
//判断该数据是否存在
- (BOOL)isExistWithId:(NSString *)idStr
{
    BOOL isExist = NO;
    FMResultSet *resultSet= [_db executeQuery:@"SELECT * FROM t_wxjdataDict where idStr = ?",idStr];
    while ([resultSet next]) {
        if([resultSet stringForColumn:@"idStr"]) {
            isExist = YES;
        }else{
            isExist = NO;
        }
    }
    return isExist;
}
//删除表
- (BOOL)deleteTable
{
    if (![_db executeUpdate:@"DROP TABLE t_wxjdataDict"]){
        return NO;
    }
    return YES;
}
//关闭数据库
- (BOOL)closeSqlite{
    BOOL isClose = [_db close];
    NSLog(isClose ? @"delete sucess" : @"delete  faliure");
    return isClose;
}
//计算缓存大小
- (CGFloat)folderSize{
    NSString*filePath = [self achieveDataBasePath];
    CGFloat folderSize = [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil].fileSize;
    //转换为M为单位
    CGFloat sizeM = folderSize /1024.0/1024.0;
    return sizeM;
}
//给表添加字段
- (void)alterTableNewKey:(NSString *)key keyType:(SQLTYPE)type{
    NSDictionary *typeDict = @{@"0":@"TEXT",@"1":@"INTEGER",@"2":@"REAL",@"3":@"BLOB"};
    NSString *typeStr = [NSString stringWithFormat:@"%lu", (unsigned long)type];
    if (![_db columnExists:key inTableWithName:@"t_wxjdataDict"]){
        
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE t_wxjdataDict ADD %@ %@",key, typeDict[typeStr]];
        BOOL worked = [_db executeUpdate:alertStr];
        NSLog(worked ? @"alert sucess" : @"alert failure");
    }
}
//数据库迁移
- (void)updateSqlite{
    NSString *dbPath = [self achieveDataBasePath];
    FMDBMigrationManager *manager = [FMDBMigrationManager managerWithDatabaseAtPath:dbPath migrationsBundle:[NSBundle mainBundle]];
    
    WXJMigrationTool *tool = [[WXJMigrationTool alloc] initWithName:@"" addVersion:2 addandExecuteUpdateStr:@"create table t_wxjDict(id integer primary key,dataDict BLOB not null,idStr text not null);"];
    [manager addMigration:tool];
    BOOL resultState = NO;
    NSError *error = nil;
    if (!manager.hasMigrationsTable) {
        resultState = [manager createMigrationsTable:&error];
    }
    resultState=[manager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];
    NSLog(resultState? @"resultState sucess":@"resultState failure");
    
}
#pragma mark private methods
// 得到表里的字段名称
- (NSArray *)getColumnArr:(NSString *)tableName db:(FMDatabase *)db
{
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        [mArr addObject:[resultSet stringForColumn:@"name"]];
    }
    return mArr;
}
//获取表字段类型
- (NSArray *)achieveTableTypeArr:(NSString *)tableName db:(FMDatabase *)db
{
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        [mArr addObject:[resultSet stringForColumn:@"type"]];
    }
    return mArr;
}
@end





























