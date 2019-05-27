//
//  WDTextBorderAttachment.m
//  WDText
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import "WDTextBorderAttachment.h"
#import "WDTextAttachment+Private.h"

@interface WDTextBorderAttachment ()

// auto calculate when set text
@property (nonatomic, assign, readonly) CGSize textSize;
@property (nonatomic, assign, readonly) CGSize subTextSize;

@property (nonatomic, assign, readonly) CGRect textRect;
@property (nonatomic, assign, readonly) CGRect subTextRect;

@property (nonatomic, strong, readonly) UIImage *image;

@end

@implementation WDTextBorderAttachment

- (instancetype)initWithText:(nullable NSAttributedString *)text
                     subText:(nullable NSAttributedString *)subText
                      offset:(CGPoint)offset
                     minSize:(CGSize)minSize {
    if (self = [super init]) {
        _text = [text copy];
        _subText = [subText copy];

        _offset = offset;

        CGSize size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        _textSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        _subTextSize = [subText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        CGFloat height = MAX(MAX(_textSize.height, _subTextSize.height) + offset.y * 2, minSize.height);
        CGFloat width = _textSize.width + offset.x * 2;
        width = subText ? width + height : width;
        width = MAX(width, minSize.width);

        self.size = CGSizeMake(width, height);
    }
    return self;
}

- (void)setRect:(CGRect)rect {
    [super setRect:rect];
    [self _updateTextRect];
    [self _createBorderImage];
}

- (void)_updateTextRect {
    CGRect rect = self.rect;
    if (!self.subText) {
        _textRect.origin = _offset;
        _textRect.size = self.textSize;
        _subTextRect = CGRectZero;
    } else {
        _textRect.origin = _offset;
        _textRect.size = self.textSize;

        CGFloat height = CGRectGetHeight(rect);

        CGFloat subTextWidth = _subTextSize.width;
        CGFloat paddingRight = (height - subTextWidth) * 0.5;

        _subTextRect.origin.x = CGRectGetWidth(rect) - subTextWidth - paddingRight - self.strokeWidth * 0.5;
        _subTextRect.origin.y = _offset.y;
        _subTextRect.size.width = height;
        _subTextRect.size.height = height;
    }
}

- (void)_createBorderImage {

    CGRect imageRect = self.rect;
    imageRect.origin = CGPointZero;

    UIGraphicsBeginImageContextWithOptions(self.rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (!context) return;

    CGFloat lineWidth = self.strokeWidth;
    UIColor *fillColor = self.fillColor ? : [UIColor clearColor];
    UIColor *strokeColor = self.strokeColor ? : [UIColor clearColor];

    // 边框
    [self drawBorderRect:imageRect lineWidth:lineWidth strokeColor:strokeColor fillColor:fillColor];

    // 右边白色底图
    BOOL single = !self.subText;
    if (!single) {
        CGFloat height = CGRectGetHeight(imageRect);

        imageRect.origin.x = CGRectGetMaxX(imageRect) - height - lineWidth;
        imageRect.size.width = height + lineWidth;

        [self drawWhiteRect:imageRect radius:_cornerRadius];
    }

    // 文字
    if (self.text) [self.text drawInRect:self.textRect];
    if (self.subText) [self.subText drawInRect:self.subTextRect];

    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)drawBorderRect:(CGRect)rect lineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor {

    CGContextRef context = UIGraphicsGetCurrentContext();

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:CGSizeMake(_cornerRadius, _cornerRadius)];
    path.usesEvenOddFillRule = YES;
    [path addClip];

    CGContextAddPath(context, path.CGPath);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawWhiteRect:(CGRect)rect radius:(CGFloat)r {

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);

    CGContextMoveToPoint(context, minX, minY);          // 左上角
    CGContextAddLineToPoint(context, minX, maxY);       // 左下角
    CGContextAddLineToPoint(context, maxX - r, maxY);   // 右下角
    CGContextAddArc(context, maxX - r, maxY - r, r, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, maxX, minY + r);   // 右上角
    CGContextAddArc(context, maxX - r, minY + r, r, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, minX, minY);       // 左上角

    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

@interface WDTextBorderAttachment (Draw)

@end

@implementation WDTextBorderAttachment (Draw)

- (void)drawRect:(CGRect)rect cancelled:(WDTextCancelled)cancelled {

    if (!self.image) return;

    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;

    if (cancelled && cancelled()) return;

    CGContextDrawImage(context, self.rect, self.image.CGImage);
}

@end
