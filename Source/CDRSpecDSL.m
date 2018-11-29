#import <XCTest/XCTest.h>
#import <Nimble/Nimble.h>
#import "CDRSpecDSL.h"
#import "CDRSpecFailure.h"

const CDRSpecBlock PENDING = ^{};

void sharedExamplesFor(NSString *name, CDRDSLSharedExampleBlock block) {
    sharedExamples(name, ^(QCKDSLSharedExampleContext context) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        beforeEach(^{
            if (context) {
                [dictionary addEntriesFromDictionary:context()];
            }
        });
        block(dictionary);
    });
}

CDRItBlock cdr_it_builder(NSDictionary *flags, NSString *file, NSUInteger line) {
    QCKItBlock itBlock = qck_it_builder(flags, file, line);
    return [[^(NSString *description, CDRDSLEmptyBlock closure) {
        itBlock(description, ^{
            @try {
                closure();
            }
            @catch (CDRSpecFailure *failure) {
                NMB_failWithMessage(failure.reason, failure.fileName, failure.lineNumber);
            }
        });
    } copy] autorelease];
}

CDRItBehavesLikeBlock cdr_itShouldBehaveLike_builder(NSDictionary *flags, NSString *file, NSUInteger line) {
    QCKItBehavesLikeBlock block = qck_itBehavesLike_builder(flags, file, line);
    return [[^(NSString *name, CDRDSLSharedExampleContext context) {
        block(name, ^NSDictionary *{
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            context(dictionary);
            return [[dictionary copy] autorelease];
        });
    } copy] autorelease];
}
