//
//  NSAttributedString+WDText.m
//  WDText
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import <CoreText/CoreText.h>

#import "NSAttributedString+WDText.h"

#import "WDTextAttachment.h"

NSString *const WDTextAttachmentAttributeName = @"WDAttachmentAttribute";

@implementation NSAttributedString (WDText)

+ (instancetype)wd_attributedStringWithAttachment:(WDTextAttachment *)attachment {

    NSDictionary *attributes = @{WDTextAttachmentAttributeName: attachment};
    CGFloat descent = attachment.descent;

    WDTextRunDelegate *delegate = [[WDTextRunDelegate alloc] init];
    delegate.ascent = attachment.size.height - descent;
    delegate.descent = descent;
    delegate.width = attachment.size.width;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;

    unichar objectReplacementChar = 0xFFFC; // 占位符
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegateRef);
    CFRelease(delegateRef);
    return space;
}

@end

@implementation WDTextRunDelegate

static void deallocCallback(void *ref) {
    WDTextRunDelegate *self = (__bridge_transfer WDTextRunDelegate *)(ref);
    self = nil; // release
}

static CGFloat ascentCallback(void *ref){
    WDTextRunDelegate *delegate = (__bridge WDTextRunDelegate *)(ref);
    return delegate.ascent;
}

static CGFloat descentCallback(void *ref){
    WDTextRunDelegate *delegate = (__bridge WDTextRunDelegate *)(ref);
    return delegate.descent;
}

static CGFloat widthCallback(void* ref){
    WDTextRunDelegate *delegate = (__bridge WDTextRunDelegate *)(ref);
    return delegate.width;
}

- (nullable CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    callbacks.dealloc = deallocCallback;
    return CTRunDelegateCreate(&callbacks, (__bridge_retained void *)(self));
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_ascent) forKey:@"ascent"];
    [aCoder encodeObject:@(_descent) forKey:@"descent"];
    [aCoder encodeObject:@(_width) forKey:@"width"];
    [aCoder encodeObject:_userInfo forKey:@"userInfo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _ascent = ((NSNumber *)[aDecoder decodeObjectForKey:@"ascent"]).floatValue;
    _descent = ((NSNumber *)[aDecoder decodeObjectForKey:@"descent"]).floatValue;
    _width = ((NSNumber *)[aDecoder decodeObjectForKey:@"width"]).floatValue;
    _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.ascent = self.ascent;
    one.descent = self.descent;
    one.width = self.width;
    one.userInfo = self.userInfo;
    return one;
}

@end
