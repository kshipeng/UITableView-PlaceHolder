//
//  FirstViewController.m
//  PlaceHolder
//
//  Created by 康世朋 on 2018/1/15.
//  Copyright © 2018年 康世朋. All rights reserved.
//

#import "FirstViewController.h"
#import "UITableView+PlaceHolder.h"

@interface FirstViewController ()<UITableViewDelegate, UITableViewDataSource, SPTableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (nonatomic, assign) NSInteger count;
@end

@implementation FirstViewController

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
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 375.0, 300.0)];
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

///** 完全自定义 */
//- (UIView *)sp_placeHolderView {
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
//    label.backgroundColor = [UIColor cyanColor];
//    label.text = @"这是一个自定义的View";
//    label.textAlignment = NSTextAlignmentCenter;
//    return label;
//}

/** 只自定义图片 */
- (UIImage *)sp_placeHolderImage {
    return [UIImage imageNamed:@"note_list_no_data"];
}

/** 只自定义文字 */
- (NSString *)sp_placeHolderMessage {
    return @"自定义的无数据提示";
}

/** 只自定义文字颜色 */
- (UIColor *)sp_placeHolderMessageColor {
    return [UIColor orangeColor];
}

/** 只自定义偏移量 */
- (NSNumber *)sp_placeHolderViewCenterYOffset {
    return @(0);
}

#pragma mark - 默认的占位图点击事件（完全自定义的view自己加点击事件就好了）
- (void)sp_placeHolderViewClick {
    NSLog(@"点击了重新加载");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
