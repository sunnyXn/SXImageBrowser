//
//  SXImageBrowseItemView.h
//  SXImageBrowser
//
//  Created by Sunny on 2022/10/21.
//

#import <UIKit/UIKit.h>




@interface SXImageBrowseItemView : UIScrollView <UIScrollViewDelegate>


@property(nonatomic, strong, readonly) UIImageView *imageView;

/// 图片未缩放时尺寸
@property(nonatomic, assign) CGSize imageNormalSize;

//缩放方法，共外界调用
- (void)zoomWithScale:(CGFloat)zoomScale;


@end


