//
//  TableViewCell.m
//  Example
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import <WDText/WDText.h>

#import "TableViewCell.h"

@interface TableViewCell () <WDTextLabelDelegate>

@property (nonatomic, strong) WDTextLabel *label;

@end

@implementation TableViewCell

- (void)setViewModel:(CellViewModel *)viewModel {
    if (_viewModel != viewModel) {
        _viewModel = viewModel;
        self.label.textLayout = viewModel.textLayout;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];

        self.label = [[WDTextLabel alloc] init];
        self.label.delegate = self;
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectMake(5, 5, self.bounds.size.width - 10, self.viewModel.height - 10);
}

#pragma mark - WDTextLabelDelegate

- (void)textLabel:(WDTextLabel *)textLabel onTapAttachment:(__kindof WDTextAttachment *)attachment {
    NSLog(@"%@", attachment.action);
}

- (void)textLabel:(WDTextLabel *)textLabel onTapLink:(NSString *)link {
    NSLog(@"linkValue: %@", link);
}

@end
