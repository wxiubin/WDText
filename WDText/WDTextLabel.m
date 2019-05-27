//
//  WDTextLabel.m
//  WDText
//
//  Created by wxiubin on 2019/5/27.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import "WDTextLabel.h"

#import "WDTextLayer.h"
#import "WDTextLayout.h"

@interface WDTextLabel () <UIGestureRecognizerDelegate> {
    CGRect _rect;
}

@end

@implementation WDTextLabel

+ (Class)layerClass {
    return WDTextLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _initialize];
    }
    return self;
}

#pragma mark - Private

- (void)_initialize {
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_userTapGestureDetected:)];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];

    _tapGestureRecognizer = tapGestureRecognizer;
}

- (void)_userTapGestureDetected:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];

    WDTextAttachment *attachment = [self.textLayout attachmentAtPoint:point inView:self];
    if (attachment.action.length) return [self _onTapAttachment:attachment];

    id linkValue = [self.textLayout linkValueAtPoint:point inView:self];
    if (linkValue) [self _onTapLink:linkValue];
}

- (void)_onTapAttachment:(WDTextAttachment *)attachment {
    if ([self.delegate respondsToSelector:@selector(textLabel:onTapAttachment:)]) {
        [self.delegate textLabel:self onTapAttachment:attachment];
    }
}

- (void)_onTapLink:(NSString *)link {
    if ([self.delegate respondsToSelector:@selector(textLabel:onTapLink:)]) {
        [self.delegate textLabel:self onTapLink:link];
    }
}

#pragma mark - WDTextLayerDelegate

- (WDTextLayerDisplayTask *)displayTask {

    WDTextLayerDisplayTask *task = [[WDTextLayerDisplayTask alloc] init];

    CGRect rect = _rect;
    WDTextLayout *textLayout = self.textLayout;

    task.display = ^(CGContextRef  _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancelled)(void)) {
        [textLayout drawRect:rect cancelled:isCancelled];
    };

    return task;
}

#pragma mark - UIGestureRecognizerDelegate


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return !!self.delegate;
}

- (void)setTextLayout:(WDTextLayout *)textLayout {
    if (_textLayout != textLayout) {
        _textLayout = textLayout;
        [self.layer setNeedsDisplay];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _rect = self.bounds;
}

@end
