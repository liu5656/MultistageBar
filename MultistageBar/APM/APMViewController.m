//
//  APMViewController.m
//  MultistageBar
//
//  Created by x on 2022/1/10.
//  Copyright © 2022 x. All rights reserved.
//

#import "APMViewController.h"

#import <mach/mach_init.h>
#import <mach/task.h>
#import <mach/thread_act.h>
#import <mach/vm_map.h>

//#include <mach/task.h>
//#include <mach/mach_init.h>

@interface APMViewController ()

@end

@implementation APMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"cpu usage: %f", [APMViewController cpuUsage]);
    NSLog(@"memory usage : %d", [APMViewController memoryUsage]);
    
}

+ (CGFloat)cpuUsage {
    kern_return_t           status;
    thread_array_t          threads;
    mach_msg_type_number_t  threadCount;
    
    thread_info_data_t      threadInfo;
    thread_basic_info_t     threadBasicInfo;
    mach_msg_type_number_t  threadBasicInfoCount;
    
    status = task_threads(mach_task_self(), &threads, &threadCount);
    if (status != KERN_SUCCESS) {
        return -1;
    }
    float cpuUsage = 0;
    for (int i = 0; i < threadCount; i++) {
        threadBasicInfoCount = THREAD_INFO_MAX;
        status = thread_info(threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadBasicInfoCount);
        if (status != KERN_SUCCESS) {
            return  -1;
        }
        threadBasicInfo = (thread_basic_info_t)threadInfo;
        if ((threadBasicInfo->flags & TH_FLAGS_IDLE) == false) {
            cpuUsage += threadBasicInfo->cpu_usage / (float)TH_USAGE_SCALE;
        }
    }
    status = vm_deallocate(mach_task_self(), (vm_offset_t)threads, threadCount * sizeof(thread_t));
    assert(status == KERN_SUCCESS);
    
    return cpuUsage;
}

+ (NSInteger)memoryUsage {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t status = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &count);
    assert(status == KERN_SUCCESS);
    int64_t memoryByte = (int64_t)vmInfo.phys_footprint;
    return  memoryByte / 1024 / 1024;
}


@end
