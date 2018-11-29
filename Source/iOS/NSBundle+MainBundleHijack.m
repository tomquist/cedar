#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@implementation NSBundle (MainBundleHijack)
static NSBundle *mainBundle__ = nil;

NSBundle *CDRMainBundle(id self, SEL _cmd) {
    return mainBundle__;
}

NSString *CDRGetTestBundleExtension() {
    NSString *extension = nil;;
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    NSSet *xctestFlags = [NSSet setWithArray:@[@"-XCTest", @"-XCTestScopeFile"]];
    if ([xctestFlags intersectsSet:[NSSet setWithArray:arguments]]) {
        extension = @".xctest";
    } else if ([arguments containsObject:@"-SenTest"]) {
        extension = @".octest";
    } else if ((BOOL)NSClassFromString(@"XCTestCase")) {
        extension = @".xctest";
    }

    return extension;
}

void CDRSuppressStandardPipesWhileLoadingClasses() {
    if (getenv("CEDAR_VERBOSE")) {
        int saved_stdout = dup(STDOUT_FILENO);
        int saved_stderr = dup(STDERR_FILENO);
        freopen("/dev/null", "w", stdout);
        freopen("/dev/null", "w", stderr);

        unsigned int count = 0;
        Class *classes = objc_copyClassList(&count);
        for (int i = 0; i < count; i++) {
            if (class_respondsToSelector(classes[i], @selector(initialize))) {
                [classes[i] class];
            }
        }
        free(classes);

        dup2(saved_stdout, STDOUT_FILENO);
        dup2(saved_stderr, STDERR_FILENO);
    }
}

+ (void)load {
    CDRSuppressStandardPipesWhileLoadingClasses();

    NSString *extension = CDRGetTestBundleExtension();

    if (!extension) {
        return;
    }

    BOOL mainBundleIsApp = [[[NSBundle mainBundle] bundlePath] hasSuffix:@".app"];
    BOOL mainBundleIsTestBundle = [[[NSBundle mainBundle] bundlePath] hasSuffix:extension];

    if (!mainBundleIsApp && !mainBundleIsTestBundle) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        for (NSBundle *bundle in [NSBundle allBundles]) {
            if ([[bundle bundlePath] hasSuffix:extension]) {
                mainBundle__ = [bundle retain];
                Class nsBundleMetaClass = objc_getMetaClass("NSBundle");
                class_replaceMethod(nsBundleMetaClass, @selector(mainBundle), (IMP)CDRMainBundle, "v@:");
            }
        }
        [pool drain];
    }
}

@end
