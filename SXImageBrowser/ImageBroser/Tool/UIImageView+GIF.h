//
//  UIImageView+GIF.h
//  SXImageBrowser
//
//  Created by Sunny on 2022/10/21.
//

#import <UIKit/UIKit.h>



@interface UIImageView (GIF)


- (void)showGifImageWithData:(NSData *)data;

- (void)showGifImageWithURL:(NSURL *)url;

- (NSString *)contentTypeForImageData:(NSData *)data;


@end


