//
//  DependencyInjection.h
//  Pods
//
//  Created by Schell Scivally on 1/27/16.
//
//

#import <Foundation/Foundation.h>

@protocol DependencyInjection <NSObject>

+ (void)setDIClass:(Class)class;
+ (Class)DIClass;

#define SYNTHESIZE_DI \
static Class __DIClass = nil; \
+ (void)setDIClass:(Class)class { \
    if ([class isSubclassOfClass:[self class]]) { \
        __DIClass = class; \
    } else { \
        [NSException raise:@"Dependency Injection Error" format:@"Class %@ is not a subclass of %@",class,[self class]]; \
    } \
} \
\
+ (Class)DIClass { \
    if (__DIClass == nil) { \
        __DIClass = [self class]; \
    } \
    return __DIClass; \
}

@end
