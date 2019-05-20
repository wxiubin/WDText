//
//  ViewController.m
//  Example
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import "ViewController.h"

#import "MemoryWatcher.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray<CellViewModel *> *viewModels;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (IBAction)refresh:(UIBarButtonItem *)sender {

    if (!self.timer.isValid) {
        [self _setupTimer];
    } else {
        [self.timer invalidate];
    }

}

- (void)_setupTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.4f
                                                  target:self
                                                selector:@selector(_timerAction)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)_timerAction {

    const int count = 30;

    NSInteger total = self.viewModels.count;

    if (total > 200) {
        [MemoryWatcher log];
        [self.viewModels removeAllObjects];
        [self.tableView reloadData];
    }

    __block NSMutableArray *array = nil;
    [self _async:^{
        array = [self _itemViewModelsWithCount:count];
    } completion:^{
        [self.viewModels addObjectsFromArray:array];
        NSInteger total = self.viewModels.count;
        self.title = @(total).stringValue;
        [self.tableView reloadData];

        if (!total) return;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:total-1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }];
}

- (void)_async:(void (^)(void))block completion:(void (^)(void))completion {
    static dispatch_queue_t layoutQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layoutQueue = dispatch_queue_create("com.bilibili.live.layout.danmaku", NULL);
    });
    dispatch_async(layoutQueue, ^{
        if (block) block();
        if (completion) dispatch_async(dispatch_get_main_queue(), completion);
    });
}

- (NSMutableArray *)_itemViewModelsWithCount:(NSUInteger)count {
    NSMutableArray *temp = [NSMutableArray array];
    while (count--) {
        [temp addObject:[CellViewModel new]];
    }
    return temp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:TableViewCell.class forCellReuseIdentifier:@"TableViewCell"];
    self.tableView.backgroundColor = HEXCOLOR(0xeeeeee);

    self.viewModels = [NSMutableArray array];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self _setupTimer];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.viewModels[indexPath.row].height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    cell.viewModel = self.viewModels[indexPath.row];
    return cell;
}

@end
