//
//  ViewController.m
//  ImageCache
//
//  Created by forever on 2016/10/13.
//  Copyright © 2016年 WM. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "TestModel.h"
#import "MBProgressHUD.h"
#define CachedImageFile(url) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[url lastPathComponent]]

static NSString *const cellID = @"cellid";


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UITableView *maintableview;

@property (nonatomic, strong) NSMutableDictionary *operations;
@property (nonatomic, strong) NSMutableDictionary *imgsDic;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [_maintableview registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    _maintableview.estimatedRowHeight = 100;
    _maintableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self loadData];
}

- (void)loadData
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://api.youqudao.com/mhapi/api/recommend?customerId=1964843&uuid=ac:f7:f3:48:ec:71&market=6&appversion=21"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.maintableview animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"正在玩命加载....";
    hud.color = [UIColor blackColor];
    hud.progress = 0.5;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.maintableview animated:YES];
         NSDictionary *content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray *arr = content[@"data"][@"sliders"];
        for (int i = 0; i < arr.count; i++) {
            TestModel *model = [[TestModel alloc] init];
            model.url = arr[i][@"pic"];
            [self.dataSource addObject:model];
        }
        [self.maintableview reloadData];
        
    }];
    
    [task resume];
}





#pragma mark tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestModel *model = self.dataSource[indexPath.row];
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    UIImage *image = self.imgsDic[model.url];
    if (image) {
        cell.KimageView.image = image;
    } else {
        NSString *file = CachedImageFile(model.url);
        NSData *data = [NSData dataWithContentsOfFile:file];
        if (data) {
            image = [UIImage imageWithData:data];
            cell.KimageView.image = image;
        } else {
            cell.KimageView.image = [UIImage imageNamed:@"1.png"];
            [self downloadImageWithURL:model.url index:indexPath];
        }
    }
    return cell;
}

- (void)downloadImageWithURL:(NSString *)imageUrl index:(NSIndexPath *)indexPath
{
    NSOperation *operation = self.operations[imageUrl];
    if (operation) {
        return;
    }
    __weak typeof(self) weakself = self;
    operation = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url]; // 下载
        UIImage *image = [UIImage imageWithData:data]; // NSData -> UIImage
        
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (image) {
                // 如果存在图片（下载完成），存放图片到图片缓存字典中
                weakself.imgsDic[imageUrl] = image;
                
                //将图片存入沙盒中
                //1. 先将图片转化为NSData
                NSData *data = UIImagePNGRepresentation(image);
                
                //2.  再生成缓存路径
                [data writeToFile:CachedImageFile(imageUrl) atomically:YES];
            }
            
            // 从字典中移除下载操作 (保证下载失败后，能重新下载)
            [weakself.operations removeObjectForKey:imageUrl];
            
            // 刷新当前表格，减少系统开销
            [weakself.maintableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
    
    // 添加下载操作到队列中
    [self.queue addOperation:operation];
    
    // 将当前下载操作添加到下载操作缓存中 (为了解决重复下载)
    self.operations[imageUrl] = operation;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
