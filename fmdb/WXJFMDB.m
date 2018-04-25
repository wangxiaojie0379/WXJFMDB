//
//  WXJFMDB.m
//  fmdb
//
//  Created by 王晓杰 on 2018/4/9.
//  Copyright © 2018年 王晓杰. All rights reserved.
//

#import "WXJFMDB.h"

#import "WXJMigrationTool.h"
#import <FMDBMigrationManager.h>


@interface WXJFMDB()
@property(nonatomic, strong) FMDatabase *db;
@property(nonatomic, strong) NSString *path;
@property(nonatomic, strong) NSString *tableName;//旧表名字
@property(nonatomic, strong) NSString *upName;//新表名字
@property(nonatomic, assign) BOOL isMigrateSucess;//是否迁移完成
@end

@implementation WXJFMDB

- (instancetype)initWithPath:(NSString *)path tableName:(NSString *)tableName{
    self = [super init];
    if (self) {
        _isMigrateSucess = NO;
        _path = path;
        _tableName = tableName;
        [self creatSqliteL:[self achieveDataBasePath] tableName:tableName];
    }
    return self;
}
//修改表的名字
- (void)changeTableName:(NSString *)oldName newName:(NSString *)newName{
    _tableName = oldName;
    _upName = newName;
}
//获取文件路径
- (NSString *)achieveDataBasePath{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"itemDb.sqlite"];
    if (_path == nil || [_path isEqualToString:@""]) {
        _path = filePath;
    }
    return filePath;
}
//创建数据库
- (void)creatSqliteL:(NSString *)path tableName:(NSString *)tableName{
    if ([path isEqualToString:@""]) {
        NSLog(@"sqlite path length == 0");
        return;
    }
    if ([_tableName isEqualToString:@""]) {
        NSLog(@"tableName length == 0");
        return;
    }
    NSLog(@"%@", path);
    _db = [FMDatabase databaseWithPath:path];
    BOOL isDbOpen = [_db open];
    if (isDbOpen) {
        NSString *creatStr = [NSString stringWithFormat:@"create table if not exists %@(id integer primary key,dataDict BLOB not null,idStr text not null);", tableName];
        BOOL isCreatTable = [_db executeUpdate:creatStr];
        NSLog(isCreatTable ? @"creat table sucess" : @"creat table faliure");
    }else{
        NSLog(@"sqlite open failure");
    }
}
//插入数据
- (BOOL)insertData:(id)dataDict idStr:(NSString *)idStr{
    if ([self isExistWithId:idStr tableName:_tableName]) {
        NSLog(@"idStr has exist");
        return NO;
    }
//    BOOL isInsert = [_db executeUpdateWithFormat:@"insert into t_wxjdataDict(dataDict,idStr) values(%@,%@);",[self dictTransformData:dataDict],idStr];
    NSData *data = nil;
    if (![dataDict isKindOfClass:[NSDictionary class]] && ![dataDict isKindOfClass:[NSData class]]) {
        NSLog(@"请传入正确的dataDict");
        return NO;
    }
    if ([dataDict isKindOfClass:[NSDictionary class]]) {
        data = [self dictTransformData:dataDict];
    }
    if ([dataDict isKindOfClass:[NSData class]]) {
        data = dataDict;
    }
    NSMutableString *finalStr = [NSMutableString stringWithFormat:@"insert into %@", _tableName];
    [finalStr appendString:@"(dataDict,idStr) values(?,?)"];
    BOOL isInsert = [_db executeUpdate:finalStr, data, idStr];
    NSLog(isInsert ? @"insert sucess" : @"insert  faliure");
    return isInsert;
}
//更新数据
- (BOOL)updataData:(id)dataDict idStr:(NSString *)idStr{
    NSData *data = nil;
    if (![dataDict isKindOfClass:[NSDictionary class]] && ![dataDict isKindOfClass:[NSData class]]) {
        NSLog(@"请传入正确的dataDict");
        return NO;
    }
    if ([dataDict isKindOfClass:[NSDictionary class]]) {
        data = [self dictTransformData:dataDict];
    }
    if ([dataDict isKindOfClass:[NSData class]]) {
        data = dataDict;
    }
    NSMutableString *finalStr = [NSMutableString stringWithFormat:@"update %@ set ", _tableName];
    [finalStr appendFormat:@"dataDict=?,idStr = ?"];
    BOOL isUpdate = [_db executeUpdate:finalStr, data, idStr];
//    BOOL isUpdate = [_db executeUpdateWithFormat:@"update t_wxjdataDict set dataDict=%@,idStr = %@",[self dictTransformData:dataDict],idStr];
    NSLog(isUpdate ? @"update sucess" : @"update  faliure");
    return isUpdate;
}
//删除某条数据
- (BOOL)deleteData:(NSString *)idStr{
//    if (![self isExistWithId:idStr tableName:_tableName]) {
//        NSLog(@"data has not");
//        return NO;
//    }
    NSMutableString *finalStr = [NSMutableString stringWithFormat:@"delete from %@ where ", _tableName];
    [finalStr appendString:@"idStr = ?"];
    BOOL isDelete = [_db executeUpdate:finalStr, idStr];
//    BOOL isDelete = [_db executeUpdateWithFormat:@"delete from t_wxjdataDict where idStr = %@",idStr];
    NSLog(isDelete ? @"delete sucess" : @"delete  faliure");
    return isDelete;
}
//删除全部
- (BOOL)deleteAllData{
    NSString *finalStr = [NSString stringWithFormat:@"DELETE FROM %@", _tableName];
    BOOL res = [_db executeUpdate:finalStr];
//    BOOL res = [_db executeUpdate:@"DELETE FROM t_wxjdataDict"];
    NSLog(res?@"clear all sucess":@"clear all faliure");
    return res;
}
//查找全部数据
- (NSMutableArray *)queryAllData{
    NSMutableString *finalStr = [NSMutableString stringWithFormat:@"SELECT * FROM %@", _tableName];
    FMResultSet *set = [_db executeQuery:finalStr];
    NSMutableArray *list = [NSMutableArray array];
    while (set.next) {
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
    
    NSMutableString *finalStr = [NSMutableString stringWithFormat:@"SELECT * FROM %@ where ", _tableName];
    [finalStr appendFormat:@"idStr = ?"];
    FMResultSet *set = [_db executeQuery:finalStr, idStr];
//    FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_wxjdataDict where idStr = ?", idStr];
    NSMutableArray *list = [NSMutableArray array];
    while (set.next) {
        NSLog(@"%@", [set objectForColumn:@"dataDict"]);
        // 获得当前所指向的数据
        NSData *dataStr = [set dataForColumn:@"dataDict"];
        NSDictionary *dictionary =[NSJSONSerialization JSONObjectWithData:dataStr options:NSJSONReadingMutableLeaves error:nil];
        [list addObject:dictionary];
    }
    return list;
}
//判断该数据是否存在
- (BOOL)isExistWithId:(NSString *)idStr tableName:(NSString *)tableName
{
    BOOL isExist = NO;
    NSMutableString *finalStr = [NSMutableString stringWithFormat:@"SELECT * FROM %@ where ", tableName];
    [finalStr appendFormat:@"idStr = ?"];
    FMResultSet *resultSet = [_db executeQuery:finalStr, idStr];
//    FMResultSet *resultSet= [_db executeQuery:@"SELECT * FROM t_wxjdataDict where idStr = ?",idStr];
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
- (BOOL)deleteTable:(NSString *)tableName
{
    NSString *finalStr = [NSString stringWithFormat:@"DROP TABLE %@", _tableName];
    if (![_db executeUpdate:finalStr]){
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
    if (![_db columnExists:key inTableWithName:_tableName]){
        
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@",_tableName,key, typeDict[typeStr]];
        BOOL worked = [_db executeUpdate:alertStr];
        NSLog(worked ? @"alert sucess" : @"alert failure");
    }
}
//创建新表做数据迁移
- (BOOL)creatNewTable:(NSString *)tableName{
    _upName = tableName;
    _isMigrateSucess = NO;
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"create table if not exists %@ (id  INTEGER PRIMARY KEY,", tableName];
    NSDictionary *dic = [self achieveType:_tableName];
    int keyCount = 0;
    for (NSString *key in dic) {
        keyCount++;
        if ([key isEqualToString:@"id"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    NSLog(@"%@", fieldStr);
    BOOL creatFlag = [_db executeUpdate:fieldStr];
    [self achieveAllDataContent:_tableName];
    NSLog(creatFlag ? @"creat new table sucess":@"creat new table failure");
    [self readOldTableDataAddNewTableData];
    NSLog(_isMigrateSucess? @"migrateSucess":@"migrateFailure");
    return _isMigrateSucess;
}
//读取旧表数据到新表
- (void)readOldTableDataAddNewTableData{
    NSMutableArray *dataArray = [self achieveAllDataContent:_tableName];
    NSLog(@"%@", dataArray);
    [_db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        for (NSDictionary *dict in dataArray) {
            [self insertOldDataToNewTable:dict[@"dataDict"] idStr:dict[@"idStr"]];
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_db rollback];
    }
    @finally {
        if (!isRollBack) {
            [_db commit];
            _isMigrateSucess = YES;
        }
    }
}
- (BOOL)insertOldDataToNewTable:(NSData *)dataDict idStr:(NSString *)idStr{
    if ([self isExistWithId:idStr tableName:_upName]) {
        NSLog(@"idStr has exist");
        return NO;
    }
    NSMutableString *finalStr = [NSMutableString stringWithFormat:@"insert into %@", _upName];
    [finalStr appendString:@"(dataDict,idStr) values(?,?)"];
    BOOL isInsert = [_db executeUpdate:finalStr, dataDict, idStr];
    NSLog(isInsert ? @"insert sucess" : @"insert  faliure");
    return isInsert;
}
//获取所有字段数据
- (NSMutableArray *)achieveAllDataContent:(NSString *)tableName{
    NSMutableString *finalStr = [NSMutableString stringWithFormat:@"SELECT * FROM %@", _tableName];
    FMResultSet *set = [_db executeQuery:finalStr];
    NSMutableArray *list = [NSMutableArray array];
    NSArray *nameArray = [self getColumnArr:tableName db:_db];
    NSArray *typeArray = [self achieveTableTypeArr:tableName db:_db];
    while (set.next) {
        NSMutableDictionary *adict = [@{} mutableCopy];
        for (int i = 0; i < nameArray.count; i++) {
            if ([[set stringForColumn:nameArray[i]] isKindOfClass:[NSNull class]]) {
                [adict setObject:@"" forKey:nameArray[i]];
                break;
            }
            if ([typeArray[i] isEqualToString:@"text"]) {
                [adict setObject:[set stringForColumn:nameArray[i]] forKey:nameArray[i]];
            } else if ([typeArray[i] isEqualToString:@"BLOB"]) {
                [adict setObject:[set dataForColumn:nameArray[i]] forKey:nameArray[i]];
            } else {
                [adict setObject:[NSNumber numberWithLongLong:[set longLongIntForColumn:nameArray[i]]] forKey:nameArray[i]];
            }
            NSLog(@"achieveAllDataContent%@", adict);
        }
        [list addObject:adict];
    }
    return list;
}
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
//把表字段name和type放到dict里面
- (NSDictionary *)achieveType:(NSString *)tableName{
    NSMutableDictionary *mutDict = [@{} mutableCopy];
    NSArray *nameArray = [self getColumnArr:tableName db:_db];
    NSArray *typeArray = [self achieveTableTypeArr:tableName db:_db];
    if (typeArray.count == typeArray.count) {
        for (int i = 0; i < nameArray.count; i++) {
            [mutDict setObject:typeArray[i] forKey:nameArray[i]];
        }
    }
    return [mutDict copy];
}
//字典转data
- (NSData *)dictTransformData:(NSDictionary *)dataDict{
    NSData *data= [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
    return data;
}
@end





























