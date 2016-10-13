//
//  WMImageCache.h
//  ImageCache
//
//  Created by forever on 2016/10/13.
//  Copyright © 2016年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WMImageCache : NSObject

+ (WMImageCache *)shareImageCache;

- (UIImage *)wm_setImageWithURL:(NSString *)url;

@end
