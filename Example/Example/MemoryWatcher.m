//
//  MemoryWatcher.m
//  CoreTextDemo
//
//  Created by wxiubin on 2019/3/29.
//  Copyright © 2019 wxiubin. All rights reserved.
//

#include <mach/mach.h>

#import <UIKit/UIKit.h>

#import "MemoryWatcher.h"

@implementation MemoryWatcher

+ (void)log {

    const NSInteger logLabelTag = 98980;

    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UILabel *label = [keyWindow viewWithTag:logLabelTag];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(80, 40, 60, 20)];
        label.tag = logLabelTag;
        label.font = [UIFont systemFontOfSize:11];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor greenColor];
        [keyWindow addSubview:label];
    }

    NSString *text = [NSString stringWithFormat:@"%@ M", @(MemoryWatcher.applicationUseMemory)];

    label.text = text;
    NSLog(@"%@", text);
}

+ (SInt64)applicationUseMemory {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    int64_t useMemory = (int64_t) vmInfo.phys_footprint;
    return (kernelReturn == KERN_SUCCESS) ? (useMemory / 1024 / 1024) : -1; // size in bytes
}

+ (SInt64)deviceFreeMemory {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;

    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size / 1024 / 1024;
}

+ (SInt64)deviceTotalMemory {
    return [NSProcessInfo processInfo].physicalMemory / 1024 / 1024;
}

@end
