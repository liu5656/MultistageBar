//
//  APMDetector.m
//  MultistageBar
//
//  Created by x on 2022/1/10.
//  Copyright © 2022 x. All rights reserved.
//

#import "APMDetector.h"

@interface APMDetector()

{
    CFRunLoopActivity activity;
    dispatch_semaphore_t semaphore;
    UInt64 timeoutCount;
}

@end

@implementation APMDetector

- (void)registerObserver {
    CFRunLoopObserverContext context = {0, (__bridge void *) self, NULL, NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities,
                                                            YES,
                                                            0,
                                                            &runloopObserverCallback,
                                                            &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    semaphore = dispatch_semaphore_create(0);
    timeoutCount = 1;
    
    dispatch_queue_global_t global = dispatch_get_global_queue(0, 0);
    
    dispatch_async(global, ^{
        while (YES) {
            long st = dispatch_wait(self->semaphore, dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC));
            if (st != 0
                && (self->activity == kCFRunLoopBeforeSources || self->activity == kCFRunLoopAfterWaiting)
                && self->timeoutCount < 5) {
                self->timeoutCount++;
                continue;
            }
            self->timeoutCount = 0;
        }
    });
}

static void runloopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    
    APMDetector *detector = (__bridge APMDetector *)info;
    
    detector->activity = activity;
    
    dispatch_semaphore_signal(detector->semaphore);
    
}




static int s_fatal_signals[] = {SIGABRT, SIGBUS, SIGFPE, SIGILL, SIGSEGV, SIGTRAP, SIGTERM, SIGKILL};
static int s_fatal_signal_num = sizeof(s_fatal_signals) / sizeof(s_fatal_signals[0]);

void uncaughtExceptionHandler(NSException *exception) {
    NSArray *exceptionArray = [exception callStackSymbols];     // 当前调用堆栈
    NSString *exceptionString = exception.reason;
    NSString *exceptionName = exception.name;
}

void signalHandler(int code) {
    NSLog(@"signal handle = %d", code);
}

void initCrashReporter() {
    for (int i = 0; i < s_fatal_signal_num; i++) {
        signal(s_fatal_signals[i], signalHandler);
    }
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}



@end
