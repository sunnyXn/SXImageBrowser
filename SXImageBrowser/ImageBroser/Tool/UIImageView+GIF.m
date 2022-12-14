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


//??????gif?????????????????????????????????
- (NSTimeInterval)durationForGifData:(NSData *)data{
    //???GIF?????????????????????????????????
    CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    //?????????????????????????????????????????????????????????
    size_t frameCout = CGImageSourceGetCount(gifSource);
    //???????????????????????????????????????
    NSMutableArray* frames = [[NSMutableArray alloc] init];
    NSTimeInterval totalDuration = 0;
    for (size_t i=0; i<frameCout; i++) {
        //???GIF????????????????????????
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        //?????????????????????UIimageView?????????????????????
        UIImage* imageName = [UIImage imageWithCGImage:imageRef];
        //????????????????????????
        [frames addObject:imageName];
        NSTimeInterval duration = [self gifImageDeleyTime:gifSource index:i];
        totalDuration += duration;
        CGImageRelease(imageRef);
    }
    
    //??????????????????
    NSInteger loopCount;//????????????
    CFDictionaryRef properties = CGImageSourceCopyProperties(gifSource, NULL);
    if (properties) {
        CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gif) {
            CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
            if (loop) {
                //??????loop == NULL??????????????????????????????loopCount  == 0???????????????????????????
                CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
            };
        }
    }
    
    CFRelease(gifSource);
    return totalDuration;
}

//??????GIF?????????????????????
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



//??????????????????
- (NSString *)contentTypeForImageData:(NSData *)data {
    
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @"jpeg??????";
            
        case 0x89:
            
            return @"png??????";
            
        case 0x47:
            
            return @"gif??????";
            
        case 0x49:
            
        case 0x4D:
            
            return @"tiff??????";
            
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
