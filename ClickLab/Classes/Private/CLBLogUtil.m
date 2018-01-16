//
//  CLBLogUtil.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBLogUtil.h"

static BOOL kClickLabLoggerShowLogs = NO;

void CLBShowDebugLogs(BOOL showDebugLogs) {
    kClickLabLoggerShowLogs = showDebugLogs;
}

void CLBLog(NSString *format, ...) {
    if (!kClickLabLoggerShowLogs)
        return;
    
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}
