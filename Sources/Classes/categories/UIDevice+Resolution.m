//
//  UIDevice+Resolution.m
//  CocoaViewer
//
//  Created by Schell Scivally on 4/5/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "UIDevice+Resolution.h"
#import "UIViewHelper.h"
#import <sys/types.h>
#import <sys/sysctl.h>

@implementation UIDevice (Resolution)


- (UIDevicePlatformMajor)platformMajor {
    NSArray* majors = [NSArray arrayWithObjects:@"Phone",@"Pad",@"Simulator",nil];
    NSUInteger num = 0;
    NSString* platform = [self platform];
    for (NSString* major in majors) {
        if ([[platform componentsSeparatedByString:major] count] > 1) {
            return (UIDevicePlatformMajor)num;
        }
        num++;
    }
    return (UIDevicePlatformMajor)num;
}

- (NSString*)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (CGSize)screenSize {
    return [UIViewHelper screenSize];
}

- (NSString*)resolution {
    NSString* platform = [self platform];
    NSArray* platformSplit = [platform componentsSeparatedByString:@","];
    NSString* hardware = [platformSplit objectAtIndex:0];
    // model will be something like "iPad","iPad2","x86_64" (simulator)
    if ([hardware isEqualToString:@"iPad"] || [hardware isEqualToString:@"iPad1"] || [hardware isEqualToString:@"iPad2"]) {
        return @"XGA";
    }
    if ([hardware isEqualToString:@"iPad3"]) {
        return @"QXGA";
    }
    // TODO: Put in iPhone resolutions...
    
    // It's not an iPad...
    NSString* model = [self model];
    NSString* version = [self systemVersion];
    if ([model isEqualToString:@"iPad Simulator"]) {
        float fversion = [version floatValue];
        if (fversion > 5.0) {
            return @"QXGA";
        }
        return @"XGA";
    }
    
    //WTF is it? Just give em web res...
    return @"XGA";
}

- (NSArray*)listOfSupportedResolutions {
    NSString* highestSupportedResolution = [self resolution];
    NSArray* resolutions = @[@"QXGA",@"XGA",@"Web"];
    NSUInteger ndx = [resolutions indexOfObject:highestSupportedResolution];
    if (ndx == NSNotFound) {
        return @[];
    }
    NSArray* supportedResolutions = @[];
    for (NSString* res in resolutions) {
        if ([resolutions indexOfObject:res] >= ndx) {
            supportedResolutions = [supportedResolutions arrayByAddingObject:res];
        }
    }
    return supportedResolutions;
}

- (BOOL)isSimulator {
    return [[[self platform] componentsSeparatedByString:@"Simulator"] count] > 1;
}

- (NSString *)osVersionBuild {
    int mib[2] = {CTL_KERN, KERN_OSVERSION};
    u_int namelen = sizeof(mib) / sizeof(mib[0]);
    size_t bufferSize = 0;
    
    NSString *osBuildVersion = nil;
    
    // Get the size for the buffer
    sysctl(mib, namelen, NULL, &bufferSize, NULL, 0);
    
    u_char buildBuffer[bufferSize];
    int result = sysctl(mib, namelen, buildBuffer, &bufferSize, NULL, 0);
    
    if (result >= 0) {
        osBuildVersion = [[NSString alloc] initWithBytes:buildBuffer length:bufferSize encoding:NSUTF8StringEncoding];
    }
    
    return osBuildVersion;
}

@end
