//
//  QZPhotoEncoder.m
//  QZone
//
//  Created by zilinzhou on 2018/3/15.
//

#import "QZPhotoEncoder.h"
#import "QZPhotoCacheUtils.h"

const NSInteger QZBytesPerPixel = 4;
const NSInteger QZBitsPerComponent = 8;
const float QZAlignmentSize = 64;

@implementation QZPhotoEncoder

+ (BOOL)encodeImage:(UIImage *)image size:(CGSize)size bytes:(void*)bytes {
    CGFloat screenScale = [QZPhotoCacheUtils contentsScale];
    CGSize pixelSize = CGSizeMake(size.width * screenScale, size.height * screenScale);
    
    size_t bytesPerRow = ceil((pixelSize.width * QZBytesPerPixel) / QZAlignmentSize) * QZAlignmentSize;
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(bytes, pixelSize.width, pixelSize.height, QZBitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        CGContextRelease(context);
        return NO;
    }

    CGContextTranslateCTM(context, 0, pixelSize.height);
    CGContextScaleCTM(context, 1, -1);
    
    CGRect contextBounds = CGRectZero;
    contextBounds.size = pixelSize;
    CGContextClearRect(context, contextBounds);
    
    UIGraphicsPushContext(context);
    [image drawInRect:[QZPhotoCacheUtils targetRectWithImageSize:image.size destSize:pixelSize]];
    UIGraphicsPopContext();
    
    CGContextRelease(context);
    
    return YES;
}

+ (size_t)dataLengthWithImageSize:(CGSize)size {
    CGFloat screenScale = [QZPhotoCacheUtils contentsScale];
    CGSize pixelSize = CGSizeMake(size.width * screenScale, size.height * screenScale);
    size_t bytesPerRow = ceil((pixelSize.width * QZBytesPerPixel) / QZAlignmentSize) * QZAlignmentSize;
    CGFloat imageLength = bytesPerRow * (NSInteger)pixelSize.height;
    int pageSize = [QZPhotoCacheUtils pageSize];
    size_t bytesToAppend = ceil(imageLength / pageSize) * pageSize;
    
    return bytesToAppend;
}

@end
