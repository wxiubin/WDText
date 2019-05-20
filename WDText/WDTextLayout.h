//
//  WDTextLayout.h
//  WDText
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "WDTextAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface WDTextLayout : NSObject

@property (nonatomic, assign, readonly) CTFrameRef ctFrame;

@property (nonatomic, assign, readonly) CGRect rect;

@property (nonatomic, copy, readonly) NSAttributedString *attributedString;

@property (nonatomic, copy, readonly, nullable) NSArray<__kindof WDTextAttachment *> *attachments;

- (instancetype)initWithAttributedString:(NSAttributedString *)string rect:(CGRect)rect;

@end


@interface WDTextLayout (Event)

- (nullable id)linkValueAtPoint:(CGPoint)point inView:(UIView *)view;

- (nullable __kindof WDTextAttachment *)attachmentAtPoint:(CGPoint)point inView:(UIView *)view;

@end


@interface WDTextLayout (Draw) <WDTextDrawAble>

@end

NS_ASSUME_NONNULL_END
