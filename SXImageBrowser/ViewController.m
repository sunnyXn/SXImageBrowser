//
//  ViewController.m
//  SXImageBrowser
//
//  Created by Sunny on 2022/10/21.
//

#import "ViewController.h"
#import "SXImageBrowserView.h"

@interface ViewController ()

@property(nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
//    //网络gif图片URL
//    NSMutableArray * urlArray = [NSMutableArray arrayWithArray:@[@"http://p2.pstatp.com/large/c14000603985b03fb49", @"http://easyread.ph.126.net/FV6Yi84CwrNIJjMQxWApKQ==/7916821270058126176.gif", @"http://img4.duitang.com/uploads/item/201511/26/20151126134454_3dURj.jpeg",@"http://img3.duitang.com/uploads/item/201505/20/20150520150637_aEiMU.gif"]];
//
//    //本地图片名字
//    NSMutableArray * nameArray = [NSMutableArray arrayWithArray:@[@"11.gif", @"12.gif", @"wang.jpeg", @"13.gif"]];
//
//    //本地图片地址
//    NSMutableArray * pathArray  = [NSMutableArray array];
//
//    for (NSString * nameStr in nameArray) {
//
//        NSArray * nameAndType = [nameStr componentsSeparatedByString:@"."];
//        NSString * name = [nameAndType  firstObject];
//        NSString * type = [nameAndType  lastObject];
//        [pathArray addObject: [[NSBundle mainBundle] pathForResource:name ofType:type]];
//
//    }
//
//    SXImageBrowserView * browseView = [[SXImageBrowserView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    browseView.backgroundColor = [UIColor blackColor];
////    browseView.urlArray = urlArray;
//    browseView.viewController = self;
//        browseView.pathArray = pathArray;
//    //    browseView.nameArray = nameArray;
//
//    [self.view addSubview:browseView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(100, 200, 100, 50);
    [addBtn setTitle:@"点击预览" forState:UIControlStateNormal];
    [addBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = 3;
    addBtn.backgroundColor = [UIColor lightGrayColor];
    [addBtn addTarget:self action:@selector(addClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
}

- (void)setupBrowseView {
    CGSize mSize = self.view.bounds.size;
    
    SXImageBrowserView * browseView = [[SXImageBrowserView alloc] initWithFrame:CGRectMake(0, 0, mSize.width, mSize.height)];
    browseView.viewController = self;
    browseView.pathArray = self.dataArray;
    
    [self.view addSubview:browseView];
}

#pragma mark - get
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
        //本地图片名字
        NSMutableArray * nameArray = [NSMutableArray arrayWithArray:@[@"11.gif", @"12.gif", @"wang.jpeg", @"13.gif"]];

        for (NSString * nameStr in nameArray) {
            NSArray * nameAndType = [nameStr componentsSeparatedByString:@"."];
            NSString * name = [nameAndType  firstObject];
            NSString * type = [nameAndType  lastObject];
            [_dataArray addObject: [[NSBundle mainBundle] pathForResource:name ofType:type]];
        }
    }
    return _dataArray;
}

#pragma mark - response
- (void)addClickAction:(id)sender {
    [self setupBrowseView];
}


@end
