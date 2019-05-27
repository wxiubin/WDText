//
//  WDTextLabel.h
//  WDText
//
//  Created by wxiubin on 2019/5/27.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDTextLayout, WDTextAttachment, WDTextLabel;

NS_ASSUME_NONNULL_BEGIN

@protocol WDTextLabelDelegate <NSObject>

- (void)textLabel:(WDTextLabel *)textLabel onTapAttachment:(__kindof WDTextAttachment *)attachment;

- (void)textLabel:(WDTextLabel *)textLabel onTapLink:(NSString *)link;

@end

@interface WDTextLabel : UIView

@property (nonatomic, strong, nullable) WDTextLayout *textLayout;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, weak, nullable) id<WDTextLabelDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
