//
//  WDTextLayer.m
//  WDText
//
//  Created by wxiubin on 2019/5/27.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import <libkern/OSAtomic.h>
#import <UIKit/UIKit.h>

#import "WDTextLayer.h"

@implementation WDTextLayerDisplayTask
@end

/// copy from YYText
@interface _MDTextSentinel : NSObject
@property (atomic, readonly) int32_t value;
- (int32_t)increase;
@end

@implementation _MDTextSentinel {
    int32_t _value;
}
- (int32_t)value {
    return _value;
}
- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}
@end

@interface WDTextLayer () {
    _MDTextSentinel *_sentinel;
}

@end

@implementation WDTextLayer
@dynamic delegate;

- (void)display {
    [super display];
    [_sentinel increase];
    [self _display];
}

- (void)dealloc {
    [_sentinel increase];
}

- (void)_display {
    WDTextLayerDisplayTask *task = [self.delegate displayTask];
    if (!task.display) {
        if (task.willDisplay) task.willDisplay(self);
        self.contents = nil;
        if (task.didDisplay) task.didDisplay(self, YES);
        return;
    }
    _MDTextSentinel *sentinel = _sentinel;
    int32_t value = sentinel.value;
    BOOL (^isCancelled)(void) = ^BOOL() {
        return value != sentinel.value;
    };

    CGSize size = self.bounds.size;
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;

    dispatch_async([self _queue], ^{
        if (isCancelled()) return;
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        task.display(context, size, isCancelled);
        if (isCancelled()) {
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.didDisplay) task.didDisplay(self, NO);
            });
            return;
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (isCancelled()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.didDisplay) task.didDisplay(self, NO);
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isCancelled()) {
                if (task.didDisplay) task.didDisplay(self, NO);
            } else {
                self.contents = (__bridge id)(image.CGImage);
                if (task.didDisplay) task.didDisplay(self, YES);
            }
        });
    });
}


- (dispatch_queue_t)_queue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.WDText.layer.queue", NULL);
    });
    return queue;
}

@end
