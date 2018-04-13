//
//  ViewController.m
//  fmdb
//
//  Created by 王晓杰 on 2018/4/9.
//  Copyright © 2018年 王晓杰. All rights reserved.
//

#import "ViewController.h"
#import "FmdbViewController.h"
#import "WXJFMDB.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic, strong) WXJFMDB *fmdbHandle;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.titleArray = @[@"添加数据",@"删除数据",@"修改数据",@"查找某条数据",@"查找全部数据",@"删除全部数据",@"添加字段",@"数据库迁移"];
    [self.view addSubview:self.tableView];
    _fmdbHandle = [[WXJFMDB alloc] init];
//    [_fmdbHandle deleteAllData];
}
#pragma mark tableView delegate dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = _titleArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [_fmdbHandle insertData:@{@"name":@"王大麻子"} idStr:@"home1"];
        [_fmdbHandle insertData:@{@"name":@"小明"} idStr:@"home2"];
    }
    if (indexPath.row == 1) {
        [_fmdbHandle deleteData:@"home1"];
    }
    if (indexPath.row == 2) {
        [_fmdbHandle updataData:@{@"name":@"王五"} idStr:@"home1"];
    }
    if (indexPath.row == 3) {
        NSLog(@"%@", [_fmdbHandle queryAPieceData:@"home1"]);
    }
    if (indexPath.row == 4) {
        NSLog(@"%@", [_fmdbHandle queryAllData]);
    }
    if (indexPath.row == 5) {
        [_fmdbHandle deleteAllData];
    }
    if (indexPath.row == 6) {
        [_fmdbHandle alterTableNewKey:@"width" keyType:SQLTEXT];
    }
    if (indexPath.row == 7) {
        [_fmdbHandle updateSqlite];
    }
    
}
#pragma mark getter setter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
