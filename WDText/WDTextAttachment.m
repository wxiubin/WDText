//
//  WDTextAttachment.m
//  WDText
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import "WDTextAttachment+Private.h"

@implementation WDTextAttachment

- (instancetype)init {
    return [self initWithSize:CGSizeZero action:nil];
}

- (instancetype)initWithSize:(CGSize)size action:(NSString *)action {
    if (self = [super init]) {
        self.size = size;
        self.action = action;
        self.descent = 3.f;
    }
    return self;
}

@end

@implementation WDTextImageAttachment

@end


@implementation WDTextAttachment (Extension)

- (CGRect)transformCoordinateWithRect:(CGRect)rect {
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, CGRectGetHeight(rect));
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    return CGRectApplyAffineTransform(_rect, transform);
}

#pragma mark - WDTextDrawAble

- (void)drawRect:(CGRect)rect cancelled:(WDTextCancelled)cancelled { }

@end


@interface WDTextImageAttachment (Draw)

@end

@implementation WDTextImageAttachment (Draw)

- (void)drawRect:(CGRect)rect cancelled:(WDTextCancelled)cancelled {
    if (!self.name.length) return;

    UIImage *image = [UIImage imageNamed:self.name];
    if (!image) return;

    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;

    if (cancelled && cancelled()) return;

    CGContextDrawImage(context, self.rect, image.CGImage);
}

@end
