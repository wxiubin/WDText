//
//  TableViewCell.h
//  Example
//
//  Created by wxiubin on 2019/5/20.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell : UITableViewCell

@property (nonatomic, strong) CellViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
