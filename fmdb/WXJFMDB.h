//
//  WXJFMDB.h
//  fmdb
//
//  Created by 王晓杰 on 2018/4/9.
//  Copyright © 2018年 王晓杰. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define SQL_TEXT     @"TEXT" //文本
//#define SQL_INTEGER  @"INTEGER" //int long integer ...
//#define SQL_REAL     @"REAL" //浮点
//#define SQL_BLOB     @"BLOB" //data

//sqlite数据库类型
typedef enum : NSUInteger {
    SQLTEXT, 
    SQLINTEGER,
    SQLREAL,
    SQLBLOB,
} SQLTYPE;

@interface WXJFMDB : NSObject

+ (instancetype)shareInstance;
//插入数据
- (BOOL)insertData:(NSDictionary *)dataDict idStr:(NSString *)idStr;
//更新数据
- (BOOL)updataData:(NSDictionary *)dataDict idStr:(NSString *)idStr;
//查找全部数据
- (NSMutableArray *)queryAllData;
//查找某条数据
- (NSMutableArray *)queryAPieceData:(NSString *)idStr;
//删除某条数据
- (BOOL)deleteData:(NSString *)idStr;
//删除全部数据
- (BOOL)deleteAllData;
//判断该数据是否存在
- (BOOL)isExistWithId:(NSString *)idStr;
//删除表
- (BOOL)deleteTable;
//关闭数据库
- (BOOL)closeSqlite;
//给表添加字段
- (void)alterTableNewKey:(NSString *)key keyType:(SQLTYPE)type;
//数据库迁移
- (void)updateSqlite;
@end











