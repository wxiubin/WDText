//
//  NSAttributedString+WDText.h
//  WDText
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WDTextAttachment;

UIKIT_EXTERN NSString *const WDTextAttachmentAttributeName;

@interface NSAttributedString (WDText)

+ (instancetype)wd_attributedStringWithAttachment:(WDTextAttachment *)attachment;

@end


@interface WDTextRunDelegate : NSObject

@property (nonatomic, assign) CGFloat ascent;
@property (nonatomic, assign) CGFloat descent;
@property (nonatomic, assign) CGFloat width;

@property (nullable, nonatomic, copy) NSDictionary *userInfo;

/// Need CFRelease() the return value !!!
- (nullable CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED;

@end

NS_ASSUME_NONNULL_END
