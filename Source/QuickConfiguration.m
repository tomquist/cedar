#import <Quick/Quick.h>
#import <Quick/Quick-Swift.h>
#import "CedarDoubles.h"
#import "CDRHooks.h"
#import <objc/runtime.h>

QuickConfigurationBegin(QuickCedarDoublesConfiguration)

+ (void)enumerateClasses:(void (^)(Class, BOOL *))block {
    Class *classes = NULL;
    @try {
        int numClasses = 0;
        int newNumClasses = objc_getClassList(NULL, 0);

        while (numClasses < newNumClasses) {
            numClasses = newNumClasses;
            classes = (Class *)realloc(classes, sizeof(Class) * numClasses);
            newNumClasses = objc_getClassList(classes, numClasses);
        }

        BOOL stop = NO;
        for (int i = 0; i < numClasses && !stop; ++i) {
            Class cls = classes[i];
            block(cls, &stop);
        }
    } @finally {
        free(classes);
    }
}

+ (void)enumerateClassesOfProtocol:(Protocol *)protocol do:(void (^)(Class, BOOL *))block {
    [self enumerateClasses:^(Class cls, BOOL *stop) {
        if (class_conformsToProtocol(cls, protocol)) {
            block(cls, stop);
        }
    }];
}

+ (NSArray<Class> *)beforeEachClasses {
    static NSMutableArray<Class> *beforeEachClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        beforeEachClasses = [[NSMutableArray alloc] init];
        [self enumerateClassesOfProtocol:@protocol(CDRHooks) do:^(Class cls, BOOL *stop) {
            if ([cls respondsToSelector:@selector(beforeEach)]) {
                [beforeEachClasses addObject:cls];
            }
        }];

    });
    return beforeEachClasses;
}

+ (NSArray<Class> *)afterEachClasses {
    static NSMutableArray<Class> *afterEachClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afterEachClasses = [[NSMutableArray alloc] init];
        [self enumerateClassesOfProtocol:@protocol(CDRHooks) do:^(Class cls, BOOL *stop) {
            if (!!class_getClassMethod(cls, @selector(afterEach))) {
                [afterEachClasses addObject:cls];
            }
        }];
    });
    return afterEachClasses;
}

+ (void)configure:(Configuration *)configuration {
    [configuration beforeEachWithMetadata:^(ExampleMetadata *metadata) {
        for (Class cls in [self beforeEachClasses]) {
            [cls beforeEach];
        }
    }];
    [configuration afterEachWithMetadata:^(ExampleMetadata *metadata) {
        for (Class cls in [self afterEachClasses]) {
            [cls afterEach];
        }
    }];
}

QuickConfigurationEnd
