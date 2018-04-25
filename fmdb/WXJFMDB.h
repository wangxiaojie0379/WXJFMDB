//
//  WXJFMDB.h
//  fmdb
//
//  Created by 王晓杰 on 2018/4/9.
//  Copyright © 2018年 王晓杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
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


- (instancetype)initWithPath:(NSString *)path tableName:(NSString *)tableName;
//插入数据 id类型为NSData  NSDictionary两种
- (BOOL)insertData:(id)dataDict idStr:(NSString *)idStr;
//更新数据
- (BOOL)updataData:(id)dataDict idStr:(NSString *)idStr;
//查找全部数据
- (NSMutableArray *)queryAllData;
//查找某条数据
- (NSMutableArray *)queryAPieceData:(NSString *)idStr;
//删除某条数据
- (BOOL)deleteData:(NSString *)idStr;
//删除全部数据
- (BOOL)deleteAllData;
//判断该数据是否存在
- (BOOL)isExistWithId:(NSString *)idStr tableName:(NSString *)tableName;
//删除表
- (BOOL)deleteTable:(NSString *)tableName;
//关闭数据库
- (BOOL)closeSqlite;
//计算缓存大小
- (CGFloat)folderSize;
//给表添加字段
- (void)alterTableNewKey:(NSString *)key keyType:(SQLTYPE)type;
//数据库迁移
- (BOOL)creatNewTable:(NSString *)tableName;
//做数据库迁移该方法必须实现
- (void)changeTableName:(NSString *)oldName newName:(NSString *)newName;

@end











