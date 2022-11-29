//
//  UIDevice+Stats.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 11/6/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "UIDevice+Stats.h"
#import "UIDevice+Resolution.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

@implementation UIDevice (Stats)

- (NSString*)batteryLevelStr {
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    float life = [[UIDevice currentDevice] batteryLevel];
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    return [NSString stringWithFormat:@"%f", life];
}

- (NSString*)chargingStatus {
    UIDevice* device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    int i = [device batteryState];
    
    switch (i)
    {
        case UIDeviceBatteryStateUnplugged:
            return @"Unplugged";
            break;
        case UIDeviceBatteryStateCharging:
            return @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            return @"Full";
            break;
        default:
            break;
    }
    return @"unknown";
}

- (NSString*)appVersion {
     NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
     return [info objectForKey:@"CFBundleVersion"];
}

- (NSString*)fullAppVersion {
    NSDictionary* bundle = [[NSBundle mainBundle] infoDictionary];
    NSString* appName = [bundle objectForKey:@"CFBundleExecutable"];
    NSString* appVersion = [bundle objectForKey:@"CFBundleShortVersionString"];
    NSString* app = [NSString stringWithFormat:@"%@ %@ (%@)",
                     appName,
                     appVersion,
                     [[UIDevice currentDevice] appVersion]];
    return app;
}

- (NSString*)browser {
    BOOL isSim = [[UIDevice currentDevice] isSimulator];
    return [NSString stringWithFormat:@"%@: %@",isSim?@"iOS Simulator":@"Native iOS", [[UIDevice currentDevice] model]];
}

- (NSString*)availableMemory {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * (natural_t)pagesize;
    natural_t mem_free = (natural_t)vm_stat.free_count * (natural_t)pagesize;
    natural_t mem_total = mem_used + mem_free;
    natural_t memoryFactor = 1024;
    NSString* str = [NSString stringWithFormat:@"Used: %u MB Free: %u MB Total: %u MB", (mem_used / memoryFactor) / memoryFactor, (mem_free / memoryFactor) /memoryFactor, (mem_total /memoryFactor) /memoryFactor];
    return str;
}

- (NSString*)diskSpace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        return [NSString stringWithFormat:@"Capacity of %llu MiB with %llu MiB free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll)];
    } else {
        return @"unknown";
    }
}

@end
