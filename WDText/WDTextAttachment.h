//
//  WDTextAttachment.h
//  WDText
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^WDTextCancelled)(void);

@protocol WDTextDrawAble <NSObject>

- (void)drawRect:(CGRect)rect cancelled:(WDTextCancelled)cancelled;

@end

@interface WDTextAttachment : NSObject

@property (nonatomic, assign, readonly) CGSize size;
// Cocoa 坐标系
@property (nonatomic, assign, readonly) CGRect rect;

@property (nonatomic, assign) CGFloat descent;

@property (nonatomic, assign) NSUInteger position;

@property (nonatomic, copy, nullable) NSString *action;

- (instancetype)initWithSize:(CGSize)size action:(nullable NSString *)action;

@end


@interface WDTextImageAttachment : WDTextAttachment

@property (nonatomic, copy, nullable) NSString *name;

@end


@interface WDTextAttachment (Extension) <WDTextDrawAble>

/**
 转换 Cocoa 坐标 至 CocoaTouch

 @param rect 翻转区域
 @return CocoaTouch 坐标
 */
- (CGRect)transformCoordinateWithRect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
