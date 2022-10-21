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
    
    self.dismissScale = 0.5;
    self.maxDismissLength = self.bounds.size.width * 1.2;
    
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

#pragma mark - setupviews
- (void)setupImageView:(NSArray *)dataArray {
    CGSize mSize = self.bounds.size;
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
    
    CGFloat alpha = 1.0;
    CGFloat offsetY = 0.0;
    
    CGPoint movePoint = [pan translationInView:self];
    BOOL isFinish = NO;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            offsetY = movePoint.y;
            break;
        case UIGestureRecognizerStateEnded:
            offsetY = movePoint.y;
            isFinish = YES;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            isFinish = YES;
            break;
            
        default:
            isFinish = YES;
            break;
    }
    
    CGFloat scale = fabs(offsetY)/(self.maxDismissLength);
    NSLog(@"movePoint:%@, pan.state:%lu, offsetY:%.2f, scale:%.2f, alpha:%.2f", NSStringFromCGPoint(movePoint), pan.state, offsetY, scale, alpha);
    if (scale > 1.0) {
        scale = 1.0;
    }
    if (scale < 0.0) {
        scale = 0.0;
    }
    
    alpha = 1.0 - scale;
    
    CGAffineTransform transform = self.scrollView.transform;
    if (isFinish) {
        if (alpha >= self.dismissScale) {
            alpha = 1.0;
            movePoint = CGPointZero;
            transform = CGAffineTransformIdentity;
        }
    } else {
        CGAffineTransform transformScale = CGAffineTransformMakeScale(alpha, alpha);
        CGAffineTransform transformFrame = CGAffineTransformMakeTranslation(movePoint.x, movePoint.y);
        transform = CGAffineTransformConcat(transformScale, transformFrame);
    }
    
    NSLog(@"2222222movePoint:%@, pan.state:%lu, offsetY:%.2f, scale:%.2f, alpha:%.2f", NSStringFromCGPoint(movePoint), pan.state, offsetY, scale, alpha);
    
    [UIView animateWithDuration:0.0 animations:^{
        self.scrollView.transform = transform;
        self.backColorView.alpha = alpha;
        } completion:^(BOOL finished) {
            if (finished) {
                if (alpha < self.dismissScale && isFinish) {
                    self.alpha = 0.0;
                    if (self.superview) {
                        [self removeFromSuperview];
                    }
                }
            }
        }];
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


@end
