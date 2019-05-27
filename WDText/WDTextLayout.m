//
//  WDTextLayout.m
//  WDText
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import "WDTextLayout.h"

#import "WDTextAttachment+Private.h"
#import "NSAttributedString+WDText.h"

@implementation WDTextLayout{
@protected
    CTFrameRef _ctFrame;
    CGRect _rect;
    NSAttributedString *_attributedString;
    NSArray<__kindof WDTextAttachment *> *_attachments;
}

- (instancetype)initWithAttributedString:(NSAttributedString *)string rect:(CGRect)rect {
    if (self = [super init]) {

        CFAttributedStringRef ref = (__bridge CFAttributedStringRef)string;

        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(ref);
        rect.size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, rect.size, nil);

        _ctFrame = [self createFrameWithFramesetter:framesetter rect:rect];
        _rect = rect;
        _attributedString = string.copy;

        CFRelease(framesetter);

        [self fetchAttachment];
    }
    return self;
}

- (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter rect:(CGRect)rect {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);

    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

- (void)dealloc {
    if (_ctFrame) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

- (void)fetchAttachment {

    NSArray *lines = (NSArray *)CTFrameGetLines(_ctFrame);
    NSUInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), lineOrigins);

    int dataIndex = 0;

    NSMutableArray *attachments = [NSMutableArray array];

    for (int i = dataIndex; i < lineCount; ++i) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray * runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            WDTextAttachment *attachment = runAttributes[WDTextAttachmentAttributeName];
            if (!attachment) continue;

            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];

            WDTextRunDelegate * runDelegate = CTRunDelegateGetRefCon(delegate);
            if (![runDelegate isKindOfClass:[WDTextRunDelegate class]]) continue;

            CGRect runBounds = CGRectZero;
            CGFloat ascent = 0;
            CGFloat descent = 0;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;

            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y - descent;

            CGPathRef pathRef = CTFrameGetPath(_ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);

            attachment.rect = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);

            [attachments addObject:attachment];
        }
    }

    _attachments = attachments.count ? attachments : nil;
}


@end

@implementation WDTextLayout (Draw)

- (void)drawRect:(CGRect)rect cancelled:(WDTextCancelled)cancelled {

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGAffineTransform transform = CGContextGetCTM(context);
    if (transform.ty != 0) {
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
    }

    if (cancelled && cancelled()) return;

    CTFrameDraw(_ctFrame, context);

    for (WDTextAttachment *attachment in _attachments) {

        if (cancelled && cancelled()) return;

        [attachment drawRect:rect cancelled:cancelled];
    }
}

@end

@implementation WDTextLayout (Event)

#pragma mark - public

- (nullable __kindof WDTextAttachment *)attachmentAtPoint:(CGPoint)point inView:(UIView *)view {
    if (!self.attachments) return nil;
    for (WDTextAttachment *attachment in self.attachments) {
        CGRect frame = [attachment transformCoordinateWithRect:view.bounds];
        if (!CGRectContainsPoint(frame, point)) continue;
        return attachment;
    }
    return nil;
}

- (nullable id)linkValueAtPoint:(CGPoint)point inView:(UIView *)view {
    CTRunRef run = [self runAtPoint:point rect:view.bounds];
    return [(NSDictionary *)CTRunGetAttributes(run) valueForKey:NSLinkAttributeName];
}

#pragma mark - private

- (CTRunRef)runAtPoint:(CGPoint)point rect:(CGRect)rect {

    CTFrameRef textFrame = self.ctFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);

    if (!lines) return NULL;

    CFIndex count = CFArrayGetCount(lines);

    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);

    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, CGRectGetHeight(rect));
    transform = CGAffineTransformScale(transform, 1.f, -1.f);

    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);

        CGRect rect = CGRectApplyAffineTransform([self lineRect:line point:linePoint], transform);

        if (!CGRectContainsPoint(rect, point)) continue;

        CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                            point.y-CGRectGetMinY(rect));

        CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);

        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);

        for (int j = 0; j < runCount; j++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            CFRange runRange = CTRunGetStringRange(run);
            BOOL containIdx = runRange.location <= idx && idx <= runRange.length + runRange.location;
            if (containIdx) return run;
        }
    }
    return NULL;
}

- (CGRect)lineRect:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

@end
