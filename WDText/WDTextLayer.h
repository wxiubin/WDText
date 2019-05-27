//
//  WDTextLayer.h
//  WDText
//
//  Created by wxiubin on 2019/5/27.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class WDTextLayerDisplayTask;
@protocol WDTextLayerDelegate;

@interface WDTextLayer : CALayer

@property(nullable, weak) id <CALayerDelegate, WDTextLayerDelegate> delegate;

@end

@interface WDTextLayerDisplayTask : NSObject

@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);

@property (nullable, nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));

@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

@protocol WDTextLayerDelegate <NSObject>

- (WDTextLayerDisplayTask *)displayTask;

@end

NS_ASSUME_NONNULL_END
