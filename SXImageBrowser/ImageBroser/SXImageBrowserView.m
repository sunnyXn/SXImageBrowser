//
//  SXImageBrowserView.m
//  SXImageBrowser
//
//  Created by Sunny on 2022/10/21.
//

#import "SXImageBrowserView.h"
#import "SXImageBrowseItemView.h"
#import "UIImageView+GIF.h"
#import <Photos/Photos.h>


@interface SXImageBrowserView () <UIScrollViewDelegate>

@property(nonatomic, strong) UIView *backColorView;

@property(nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, strong) UILabel *indexLabel;

@property(nonatomic, strong) NSMutableArray *imageDataArray;

@property(nonatomic, assign) BOOL doubleTap;

@property(nonatomic, assign) NSInteger count;

@property(nonatomic, strong) SXImageBrowseItemView *currentItemView;

@property(nonatomic, copy) NSData *currentImageData;

@end



@implementation SXImageBrowserView

#pragma mark - lifecycle
- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_init];
    }
    return self;
}

#pragma mark - custom init
- (void)p_init {
    self.backgroundColor = UIColor.clearColor;
    
    self.startLocation = CGPointZero;
    self.startScrollFrame = self.bounds;
    self.dismissScale = 0.25;
    self.minZoomScale = 0.35;
    self.maxDismissLength = self.startScrollFrame.size.height * 1.2;
    self.maxVelocityY = 800;
    
    [self p_addSubViews];
    [self p_addGestureRecognizer];
}

- (void)p_addSubViews {
    [self addSubview:self.backColorView];
    [self addSubview:self.scrollView];
    [self addSubview:self.indexLabel];
}

//添加手势
- (void)p_addGestureRecognizer{
    self.userInteractionEnabled = YES;
    
    // 长按保存
    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureAction:)];
    [self addGestureRecognizer:longGestureRecognizer];
    
    // 双击放大/缩小
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureAction:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    
    // 滑动缩放
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - get
- (UIView *)backColorView {
    if (!_backColorView){
        _backColorView = [[UIView alloc] initWithFrame:self.bounds];
        _backColorView.backgroundColor = UIColor.blackColor;
    }
    return _backColorView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.bounds.size.width, 40)];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.font = [UIFont systemFontOfSize:18];
    }
    return _indexLabel;
}

#pragma mark - set
- (void)setUrlArray:(NSMutableArray *)urlArray{
    _urlArray = urlArray;
    [self setupImageView:_urlArray];
}

- (void)setPathArray:(NSMutableArray *)pathArray{
    _pathArray = pathArray;
    [self setupImageView:_pathArray];
}

- (void)setNameArray:(NSMutableArray *)nameArray{
    _nameArray = nameArray;
    [self setupImageView:_nameArray];
}

- (void)setStartScrollFrame:(CGRect)startScrollFrame {
    _startScrollFrame = startScrollFrame;
    if (!CGRectEqualToRect(_startScrollFrame, self.scrollView.frame)) {
        self.scrollView.frame = _startScrollFrame;
        self.maxDismissLength = self.startScrollFrame.size.height * 1.2;
    }
}

#pragma mark - setupviews
- (void)setupImageView:(NSArray *)dataArray {
    CGSize mSize = self.scrollView.bounds.size;
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollView.contentSize = CGSizeMake(dataArray.count * mSize.width, mSize.height);
    
    for (int i = 0; i < dataArray.count ; i++) {
        SXImageBrowseItemView *itemView = [[SXImageBrowseItemView alloc] initWithFrame:CGRectMake(i * mSize.width, 0, mSize.width, mSize.height)];
        itemView.imageNormalSize = CGSizeMake(mSize.width, mSize.width);
        if (dataArray == _pathArray) {
            //获取本地图片
            [itemView.imageView showGifImageWithData:[NSData dataWithContentsOfFile:dataArray[i]]];
            [self.imageDataArray addObject:[NSData dataWithContentsOfFile:dataArray[i]]];
            
        } else if (dataArray == _nameArray){
            //获取本地图片
            NSArray *nameStr = [dataArray[i] componentsSeparatedByString:@"."];
            NSString *name = [nameStr firstObject];
            NSString *type = [nameStr lastObject];
            [itemView.imageView showGifImageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:type]]];
            [self.imageDataArray addObject:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:type]]];
            
        } else {
            //获取网络图片
            [itemView.imageView showGifImageWithURL:[NSURL URLWithString:dataArray[i]]];
            [self.imageDataArray addObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:dataArray[i]]]];
        }
        [self.scrollView addSubview:itemView];
    }
    
    self.currentImageData = self.imageDataArray[self.currentIndex];
    self.currentItemView = self.scrollView.subviews[self.currentIndex];
    self.count = dataArray.count;
    [self refreshIndexLabel];
}

- (void)refreshIndexLabel {
    self.indexLabel.text = [NSString stringWithFormat:@"当前为：%ld/%ld", self.currentIndex + 1, self.count];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    self.currentIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width);
//    NSLog(@"滑动至第 %d", self.currentIndex);
}

//滚动完毕就会调用（如果不是人为拖拽scrollView导致滚动完毕，才会调用这个方法）
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

//开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.currentIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    //    NSLog(@"滑动至第 %d", self.currentIndex);
}

//滚动完毕后就会调用（如果是人为拖拽scrollView导致滚动完毕，才会调用这个方法）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger scrollIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    //    NSLog(@"scrollIndex %d",scrollIndex);
    if (scrollIndex != self.currentIndex) {
        //重置上一个缩放过的视图
        SXImageBrowseItemView *itemView = (SXImageBrowseItemView *)scrollView.subviews[self.currentIndex];
        [itemView zoomWithScale:1.0];
        
        self.currentIndex = scrollIndex;
        self.currentItemView = (SXImageBrowseItemView *)scrollView.subviews[self.currentIndex];
        self.currentImageData = self.imageDataArray[self.currentIndex] ;
        [self refreshIndexLabel];
    }
}

#pragma mark - gesture handle
- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint locationPoint = [pan locationInView:self];
            self.startLocation = locationPoint;
            self.scrollView.userInteractionEnabled = NO;
            self.scrollView.scrollEnabled = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self handlePanGestureStateChanged:pan];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGPoint velocity = [pan velocityInView:self];
            CGPoint movePoint = [pan translationInView:self];
            BOOL distanceArrive = fabs(movePoint.y/self.startScrollFrame.size.height) > self.dismissScale;
            BOOL velocityArrive = fabs(velocity.y) > self.maxVelocityY;
            if (distanceArrive || velocityArrive) {
                [self showDismissAnimation];
            } else {
                [self resetStatusAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)doubleTapGestureAction:(UITapGestureRecognizer *)tap{
    if (!_doubleTap) {
        [self.currentItemView zoomWithScale:self.currentItemView.maximumZoomScale];
        _doubleTap = YES;
    }else{
        [self.currentItemView zoomWithScale:self.currentItemView.minimumZoomScale];
        _doubleTap = NO;
    }
}

- (void)longGestureAction:(UILongPressGestureRecognizer *)longGr{
    if (!self.viewController) {
        return;
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * saveAction = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveImageToPhotoLibrary];
    }];
    [alertController addAction:saveAction];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancleAction];
    
    [saveAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
    [cancleAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
    
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - response action
- (void)saveImageToPhotoLibrary {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                options.shouldMoveFile = YES;
                [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:self.currentImageData options:options];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    NSLog(@"error:%@", error);
                    
                    NSString *message = success ? @"保存成功" : @"保存失败";
                    NSString *title = [self.currentItemView.imageView contentTypeForImageData:self.currentImageData];
                    
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                    [self.viewController presentViewController:alertController animated:YES completion:nil];
                    [UIView animateWithDuration:2.0 animations:^(){} completion:^(BOOL finished) {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                }];
        } else {
            // 无相册权限
        }
    }];
}

#pragma mark - handlePanGesture
- (void)handlePanGestureStateChanged:(UIPanGestureRecognizer *)pan {
    
    CGPoint locationPoint = [pan locationInView:self];
    CGPoint movePoint = [pan translationInView:self];
    
    CGFloat scale = 1 - fabs(movePoint.y)/(self.maxDismissLength);
    if (scale > 1.0) scale = 1.0;
    if (scale < self.minZoomScale) scale = self.minZoomScale;
    
    CGFloat alpha = 1.0 - fabs(movePoint.y)/(self.startScrollFrame.size.height * 0.6);
    if (alpha > 1) alpha = 1;
    if (alpha < 0) alpha = 0;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    CGPoint anchorPoint = CGPointMake(self.startLocation.x / self.startScrollFrame.size.width, self.startLocation.y / self.startScrollFrame.size.height);
    
    [UIView animateWithDuration:0.05 animations:^{
        self.scrollView.transform = transform;
        self.scrollView.layer.anchorPoint = anchorPoint;
        self.scrollView.center = locationPoint;
        self.backColorView.alpha = alpha;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)resetStatusAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.transform = CGAffineTransformIdentity;
        self.scrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.scrollView.center = CGPointMake(self.startScrollFrame.size.width * 0.5, self.startScrollFrame.size.height * 0.5);
        self.backColorView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.scrollView.scrollEnabled = YES;
        self.scrollView.userInteractionEnabled = YES;
    }];
}

- (void)showDismissAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.transform = self.scrollView.transform;
        self.backColorView.alpha = 0.0;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];
}





@end
