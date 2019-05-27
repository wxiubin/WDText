//
//  CellViewModel.m
//  Example
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import "CellViewModel.h"

#define CellViewModelBorderLineWidth ([UIScreen mainScreen].scale)

@interface CellViewModel ()

@property (nonatomic, strong) NSMutableAttributedString *string;

@property (nonatomic, strong) UIColor *textbgcolor;
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation CellViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

static int __index = 0;

- (void)initialize {

    NSString *name = @"哔哩哔哩:";
    NSString *text = [@"HXabj“钢之炼金厨师:ᘡAmy🌀晴天冠 ୨୧˙˳⋆ ԅ(¯﹃¯ԅ)”穿着、斩杀、饥渴、鬼化、以及生存最后斩碎世界！stringRange用于创建框架集的属性字符串的范围，在要装入框架的线条中进行排版。如果范围的长度部分设置为0，则框架设置继续添加线条，直到文本或空间用完为止。一个CGPath对象，指定框架的形状。在macOS 10.7或更高版本以及iOS 4.2或更高版本的版本中，路径可以是非矩形的。" stringByAppendingString:@(__index++).stringValue];

    self.string = [[NSMutableAttributedString alloc] init];

    self.attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};

    self.textbgcolor = [UIColor clearColor];

    [self appendMaster];
    [self appendEmpty];

    [self appendHost];
    [self appendEmpty];

    [self appendMedal];
    [self appendEmpty];

    [self appendZD];
    [self appendEmpty];

    [self appendVIP];
    [self appendEmpty];

    [self _appendText:name color:[UIColor redColor] font:[UIFont systemFontOfSize:14] attributes:@{NSLinkAttributeName:@"bilibili.name"}];
    [self _appendText:text color:[UIColor blackColor] font:[UIFont systemFontOfSize:14] attributes:nil];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6.;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [self _addAttribute:NSParagraphStyleAttributeName value:paragraphStyle];

    CGRect rect = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) * 0.9, 100.);
    self.textLayout = [[WDTextLayout alloc] initWithAttributedString:self.string rect:rect];
    self.height = CGRectGetHeight(self.textLayout.rect) + 10;
}

- (void)appendMedal {

    NSString *s = __index % 2 == 0 ? @"啊" : @"啊HEXO";
    s = [s stringByAppendingString:@(__index).stringValue];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont systemFontOfSize:10],
                                 NSBackgroundColorAttributeName:self.textbgcolor
                                 };
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:s attributes:attributes];

    NSAttributedString *subText = [[NSAttributedString alloc] initWithString:@((int)MIN(12, __index)).stringValue attributes:@{NSForegroundColorAttributeName: HEXCOLOR(0xA068F1), NSFontAttributeName: [UIFont systemFontOfSize:10],NSParagraphStyleAttributeName: paragraphStyle,NSBackgroundColorAttributeName:self.textbgcolor}];
    WDTextBorderAttachment *attachment = [[WDTextBorderAttachment alloc] initWithText:text subText:subText offset:CGPointMake(4, 2) minSize:CGSizeMake(16, 16)];
    attachment.action = @"点击了勋章";
    attachment.fillColor = HEXCOLOR(0xA068F1);
    attachment.strokeColor = HEXCOLOR(0xA068F1);
    attachment.strokeWidth = CellViewModelBorderLineWidth;
    attachment.cornerRadius = 2;
    [self.string appendAttributedString:[NSAttributedString wd_attributedStringWithAttachment:attachment]];
}

- (void)appendEmpty {
    WDTextAttachment *empty = [[WDTextAttachment alloc] initWithSize:CGSizeMake(3, 1) action:@"点击了空白"];
    [self _appendAttachment:empty];
}

- (void)appendVIP {
    WDTextImageAttachment *attachment = [[WDTextImageAttachment alloc] initWithSize:CGSizeMake(16, 16) action:@"点击了月费姥爷"];
    attachment.name = @"livebase_dan_month";
    [self _appendAttachment:attachment];
}

- (void)appendHost {
    NSAttributedString *text =
    [[NSAttributedString alloc] initWithString:[@"房管" stringByAppendingString:@(__index).stringValue]
                                    attributes:@{
                                                 NSForegroundColorAttributeName: HEXCOLOR(0xFEA249),
                                                 NSFontAttributeName: [UIFont systemFontOfSize:10],
                                                 NSBackgroundColorAttributeName:self.textbgcolor

                                                 }];
    WDTextBorderAttachment * attachment = [[WDTextBorderAttachment alloc] initWithText:text subText:nil offset:CGPointMake(4, 2) minSize:CGSizeMake(16, 16)];
    attachment.action = @"点击了房管";
    attachment.strokeColor = HEXCOLOR(0xFEA249);
    attachment.strokeWidth = CellViewModelBorderLineWidth;
    attachment.cornerRadius = 2;
    [self _appendAttachment:attachment];
}

- (void)appendZD {
    WDTextImageAttachment *attachment = [[WDTextImageAttachment alloc] initWithSize:CGSizeMake(18, 18) action:@"点击了总督"];
    attachment.name = @"livebase_governor_ico";
    [self _appendAttachment:attachment];
}

- (void)appendMaster {
    WDTextImageAttachment *attachment = [[WDTextImageAttachment alloc] initWithSize:CGSizeMake(16, 16) action:@"点击了姥爷"];
    attachment.name = @"livebase_dan_month";
    [self _appendAttachment:attachment];
}

- (void)appendLink {
    [self.string appendAttributedString:[[NSAttributedString alloc] initWithString:@"啊Link test 啊" attributes:@{
                                                                                                                 NSLinkAttributeName: @"link 22333",NSFontAttributeName: [UIFont systemFontOfSize:14]
                                                                                                                 }]];
}

#pragma mark - private

- (void)_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font attributes:(NSDictionary *)attributes {
    if (!text) return;
    NSMutableDictionary *mutableAttributes = attributes ? [attributes mutableCopy] : [NSMutableDictionary dictionary];
    if (color) {
        mutableAttributes[NSForegroundColorAttributeName] = (id)color.CGColor;
    }
    if (font) {
        mutableAttributes[NSFontAttributeName] = font;
    }
    [self.string appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:mutableAttributes]];
}

- (void)_addAttribute:(NSAttributedStringKey)name value:(id)value {
    [self.string addAttribute:name value:value range:NSMakeRange(0, self.string.length)];
}

- (void)_appendAttachment:(WDTextAttachment *)attachment {
    [self.string appendAttributedString:[NSAttributedString wd_attributedStringWithAttachment:attachment]];
}

@end
