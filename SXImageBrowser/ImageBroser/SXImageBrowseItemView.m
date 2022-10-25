//
//  SXImageBrowseItemView.m
//  SXImageBrowser
//
//  Created by Sunny on 2022/10/21.
//

#import "SXImageBrowseItemView.h"


@interface SXImageBrowseItemView ()

@property(nonatomic, strong, readwrite) UIImageView *imageView;

@end


@implementation SXImageBrowseItemView


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
    self.delegate = self;
    self.minimumZoomScale = 1.0f;
    self.maximumZoomScale = 2.0f;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior =  UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.imageNormalSize = self.bounds.size;
}

#pragma mark - get
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

#pragma mark - set
- (void)setImageNormalSize:(CGSize)imageNormalSize {
    _imageNormalSize = imageNormalSize;
    
    self.imageView.frame = CGRectMake(0, 0, imageNormalSize.width, imageNormalSize.height);
    self.imageView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
}

#pragma mark -- UIScrollViewDelegate
//返回需要缩放的视图控件 缩放过程中
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    NSLog(@"开始缩放");
}
//结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    NSLog(@"结束缩放");
}

//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self zoomWithScale:scrollView.zoomScale];
}

#pragma mark - response action
- (void)zoomWithScale:(CGFloat)zoomScale {
    // 延中心点缩放
    CGFloat imageScaleWidth = zoomScale * self.imageNormalSize.width;
    CGFloat imageScaleHeight = zoomScale * self.imageNormalSize.height;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    if (imageScaleWidth < self.frame.size.width) {
        imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
    }
    if (imageScaleHeight < self.frame.size.height) {
        imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
    }
    self.imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    self.contentSize = CGSizeMake(imageScaleWidth,imageScaleHeight);
}


@end
