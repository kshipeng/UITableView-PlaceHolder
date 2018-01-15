//
//  ViewController.m
//  PlaceHolder
//
//  Created by 康世朋 on 2018/1/12.
//  Copyright © 2018年 康世朋. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+PlaceHolder.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, SPTableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (nonatomic, assign) NSInteger count;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 0;
    _refresh = ({
        UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
        refresh.tintColor = [UIColor redColor];
        refresh.attributedTitle =[[NSAttributedString alloc]initWithString:@"刷新数据"];
        [refresh addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
        refresh;
    });
    [_tableView addSubview:_refresh];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 375.0, 200.0)];
    label.backgroundColor = [UIColor redColor];
    label.text = @"我是表头";
    label.textAlignment = NSTextAlignmentCenter;
    _tableView.tableHeaderView = label;
}

- (void)pullToRefresh {
    _count++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_refresh endRefreshing];
        [self.tableView reloadData];
        _tableView.loading = _count%2 ? 0:10;
        
    });
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _count%2 ? 0:10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc]init];
}

#pragma mark - 自定义 TableView 占位图

/** 完全自定义 */
- (UIView *)sp_placeHolderView {
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
    label.backgroundColor = [UIColor cyanColor];
    label.text = @"这是一个自定义的View";
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
