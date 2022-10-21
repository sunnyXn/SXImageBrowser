//
//  SXImageBrowserView.h
//  SXImageBrowser
//
//  Created by Sunny on 2022/10/21.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface SXImageBrowserView : UIView

//图片URL
@property(nonatomic, strong) NSMutableArray *urlArray;

//本地图片路径
@property(nonatomic, strong) NSMutableArray *pathArray;

//本地图片名字 如 1.gif 或者 1.jpeg ...
@property(nonatomic, strong) NSMutableArray *nameArray;

@property(nonatomic, weak) id viewController;

@property(nonatomic, assign) NSInteger currentIndex;

/// 消失比例 default = 0.5
@property(nonatomic, assign) CGFloat dismissScale;

/// 滑动消失最大长度，默认 self.width * 1.2
@property(nonatomic, assign) CGFloat maxDismissLength;


@end

NS_ASSUME_NONNULL_END
