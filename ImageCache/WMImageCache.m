//
//  WMImageCache.m
//  ImageCache
//
//  Created by forever on 2016/10/13.
//  Copyright © 2016年 WM. All rights reserved.
//

#import "WMImageCache.h"
#define CachedImageFile(url) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[url lastPathComponent]]

@interface WMImageCache ()

/**类中缓存的图片*/
@property (nonatomic, strong) NSMutableDictionary *imgDic;
/**下载队列*/
@property (nonatomic, strong) NSMutableDictionary *operations;

@end


@implementation WMImageCache

+ (WMImageCache *)shareImageCache
{
    static WMImageCache *imageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[WMImageCache alloc] init];
    });
    return imageCache;
}

- (UIImage *)wm_setImageWithURL:(NSString *)url tableview:(UITableView *)tableview
{
    UIImage *image = nil;
    image = _imgDic[url];
    if (image) {
        return image;
    } else {
        NSString *file = CachedImageFile(url);
        NSData *data = [NSData dataWithContentsOfFile:file];
        if (data) {
            image = [UIImage imageWithData:data];
            return image;
        } else {
            image = [self downloadWithURL:url];
        }
    }
    return image;
}

- (UIImage *)downloadWithURL:(NSString *)url
{
    NSBlockOperation *operation = _operations[url];
    if (operation) return nil;
    
    return nil;
}

#pragma mark getters
- (NSMutableDictionary *)imgDic
{
    if (!_imgDic) {
        _imgDic = [NSMutableDictionary dictionary];
    }
    return _imgDic;
}

- (NSMutableDictionary *)operations
{
    if (!_operations) {
        _operations = [NSMutableDictionary dictionary];
    }
    return _operations;
}

@end
