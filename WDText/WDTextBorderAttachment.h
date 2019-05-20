//
//  WDTextBorderAttachment.h
//  WDText
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import "WDTextAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface WDTextBorderAttachment : WDTextAttachment

@property (nonatomic, assign) CGFloat strokeWidth;

@property (nonatomic, strong, nullable) UIColor *strokeColor;

@property (nonatomic, strong, nullable) UIColor *fillColor;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign, readonly) CGPoint offset;

@property (nonatomic, copy, readonly, nullable) NSAttributedString *text;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *subText;

- (instancetype)initWithText:(nullable NSAttributedString *)text
                     subText:(nullable NSAttributedString *)subText
                      offset:(CGPoint)offset
                     minSize:(CGSize)minSize;

@end

NS_ASSUME_NONNULL_END
