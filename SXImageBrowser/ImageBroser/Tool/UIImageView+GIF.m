//
//  UIImageView+GIF.m
//  SXImageBrowser
//
//  Created by Sunny on 2022/10/21.
//

#import "UIImageView+GIF.h"
#import <ImageIO/ImageIO.h>


@implementation UIImageView (GIF)


- (void)animatedGIFImageSource:(CGImageSourceRef) source
                   andDuration:(NSTimeInterval) duration {
    
    
    if (!source) return;
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    for (size_t i = 0; i < count; ++i) {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!cgImage)
            return;
        [images addObject:[UIImage imageWithCGImage:cgImage]];
        CGImageRelease(cgImage);
    }
    [self setAnimationImages:images];
    [self setAnimationDuration:duration];
    [self startAnimating];
}

//- (NSTimeInterval)durationForGifData:(NSData *)data {
//    char graphicControlExtensionStartBytes[] = {0x21,0xF9,0x04};
//    double duration=0;
//    NSRange dataSearchLeftRange = NSMakeRange(0, data.length);
//    while(YES){
//        NSRange frameDescriptorRange = [data rangeOfData:[NSData dataWithBytes:graphicControlExtensionStartBytes
//                                                                        length:3]
//                                                 options:NSDataSearchBackwards
//                                                   range:dataSearchLeftRange];
//        if(frameDescriptorRange.location!=NSNotFound){
//            NSData *durationData = [data subdataWithRange:NSMakeRange(frameDescriptorRange.location+4, 2)];
//            unsigned char buffer[2];
//            [durationData getBytes:buffer];
//            double delay = (buffer[0] | buffer[1] << 8);
//            duration += delay;
//            dataSearchLeftRange = NSMakeRange(0, frameDescriptorRange.location);
//        }else{
//            break;
//        }
//    }
//    return duration/100;
//}

- (void)showGifImageWithData:(NSData *)data {
    
    NSTimeInterval duration = [self durationForGifData:data];

    NSLog(@"%f",duration);
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
    [self animatedGIFImageSource:source andDuration:duration];
    CFRelease(source);
}

- (void)showGifImageWithURL:(NSURL *)url {
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self showGifImageWithData:data];
}


//获取gif图片的总时长和循环次数
- (NSTimeInterval)durationForGifData:(NSData *)data{
    //将GIF图片转换成对应的图片源
    CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    //获取其中图片源个数，即由多少帧图片组成
    size_t frameCout = CGImageSourceGetCount(gifSource);
    //定义数组存储拆分出来的图片
    NSMutableArray* frames = [[NSMutableArray alloc] init];
    NSTimeInterval totalDuration = 0;
    for (size_t i=0; i<frameCout; i++) {
        //从GIF图片中取出源图片
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        //将图片源转换成UIimageView能使用的图片源
        UIImage* imageName = [UIImage imageWithCGImage:imageRef];
        //将图片加入数组中
        [frames addObject:imageName];
        NSTimeInterval duration = [self gifImageDeleyTime:gifSource index:i];
        totalDuration += duration;
        CGImageRelease(imageRef);
    }
    
    //获取循环次数
    NSInteger loopCount;//循环次数
    CFDictionaryRef properties = CGImageSourceCopyProperties(gifSource, NULL);
    if (properties) {
        CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gif) {
            CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
            if (loop) {
                //如果loop == NULL，表示不循环播放，当loopCount  == 0时，表示无限循环；
                CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
            };
        }
    }
    
    CFRelease(gifSource);
    return totalDuration;
}

//获取GIF图片每帧的时长
- (NSTimeInterval)gifImageDeleyTime:(CGImageSourceRef)imageSource index:(NSInteger)index {
    NSTimeInterval duration = 0;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL);
    if (imageProperties) {
        CFDictionaryRef gifProperties;
        BOOL result = CFDictionaryGetValueIfPresent(imageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties);
        if (result) {
            const void *durationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &durationValue)) {
                duration = [(__bridge NSNumber *)durationValue doubleValue];
                if (duration < 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &durationValue)) {
                        duration = [(__bridge NSNumber *)durationValue doubleValue];
                    }
                }
            }
        }
    }
    
    return duration;
}



//返回图片格式
- (NSString *)contentTypeForImageData:(NSData *)data {
    
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @"jpeg格式";
            
        case 0x89:
            
            return @"png格式";
            
        case 0x47:
            
            return @"gif格式";
            
        case 0x49:
            
        case 0x4D:
            
            return @"tiff格式";
            
        case 0x52:
            
        default:
            break;
            
    }
    
    if ([data length] < 12) {
        
        return @"";
        
    }
    return @"";
}




@end
