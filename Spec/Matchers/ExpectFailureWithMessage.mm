#import "ExpectFailureWithMessage.h"
#import "CedarMatchers.h"
#import "CDRSpecFailure.h"
#import "Cedar_Specs-Swift.h"

using namespace Cedar::Matchers;

void expectFailureWithMessage(NSString *message, CDRSpecBlock block) {
    RecordAssertions *recordAssertions = [[RecordAssertions alloc] init];
    NSArray<AssertionRecord *> *assertions = [recordAssertions record:^{
        block();
    }];
    if (![message isEqualToString:assertions.firstObject.message]) {
        NSString *reason = [NSString stringWithFormat:@"Expected failure message: <%@> but received failure message <%@>", message, assertions.firstObject.message];
        [[CDRSpecFailure specFailureWithReason:reason fileName:assertions.firstObject.fileName lineNumber:(int)assertions.firstObject.lineNumber] raise];
    } else if (assertions.count == 0) {
        fail(@"Expectation should have failed.");
    }
}

void expectExceptionWithReason(NSString *reason, CDRSpecBlock block) {
    @try {
        block();
    }
    @catch (CDRSpecFailure *x) {
        fail(@"Expected exception, but received failure.");
    }
    @catch (NSException *x) {
        if (![reason isEqualToString:x.reason]) {
            NSString *failureReason = [NSString stringWithFormat:@"Expected exception with reason: <%@> but received exception with reason <%@>", reason, x.reason];
            fail(failureReason);
        }
        return;
    }

    fail(@"Expectation should have raised an exception.");
}
