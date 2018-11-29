#import <Quick/Quick.h>
#import <Quick/Quick-Swift.h>

#define SPEC_BEGIN QuickSpecBegin
#define SPEC_END QuickSpecEnd
#define itBehavesLike qck_itBehavesLike
#define xitBehavesLike qck_xitBehavesLike
#define fitBehavesLike qck_fitBehavesLike
#undef it
#define it cdr_it
#undef xit
#define xit cdr_xit
#undef fit
#define fit cdr_fit

#define CDRSpecBlock QCKDSLEmptyBlock
#define CDRSharedExampleContext NSDictionary

extern const CDRSpecBlock _Nonnull PENDING;

typedef void (^CDRDSLSharedExampleBlock)(NSDictionary *_Nonnull);
typedef void (^CDRDSLEmptyBlock)(void);
typedef void (^CDRDSLSharedExampleContext)(NSMutableDictionary *_Nonnull);

typedef void (^CDRItBlock)(NSString *_Nonnull description, CDRDSLEmptyBlock _Nonnull closure);
typedef void (^CDRItBehavesLikeBlock)(NSString *_Nonnull, CDRDSLSharedExampleContext _Nonnull);

FOUNDATION_EXPORT void sharedExamplesFor(NSString *_Nonnull name, CDRDSLSharedExampleBlock _Nonnull closure);

#define itShouldBehaveLike cdr_itShouldBehaveLike
#define xitShouldBehaveLike cdr_xitShouldBehaveLike
#define fitShouldBehaveLike cdr_fitShouldBehaveLike

#define cdr_it cdr_it_builder(@{}, @(__FILE__), __LINE__)
#define cdr_xit cdr_it_builder(@{Filter.pending: @YES}, @(__FILE__), __LINE__)
#define cdr_fit cdr_it_builder(@{Filter.focused: @YES}, @(__FILE__), __LINE__)

#define cdr_itShouldBehaveLike cdr_itShouldBehaveLike_builder(@{}, @(__FILE__), __LINE__)
#define cdr_xitShouldBehaveLike cdr_itShouldBehaveLike_builder(@{Filter.pending: @YES}, @(__FILE__), __LINE__)
#define cdr_fitShouldBehaveLike cdr_itShouldBehaveLike_builder(@{Filter.focused: @YES}, @(__FILE__), __LINE__)

FOUNDATION_EXPORT CDRItBlock _Nonnull cdr_it_builder(NSDictionary *_Nonnull flags, NSString *_Nullable file, NSUInteger line);
FOUNDATION_EXPORT CDRItBehavesLikeBlock _Nonnull cdr_itShouldBehaveLike_builder(NSDictionary *_Nonnull flags, NSString *_Nullable file, NSUInteger line);

#define SHARED_EXAMPLE_GROUPS_BEGIN(name) QuickConfigurationBegin(name) \
+ (void)configure:(Configuration *)configuration {

#define SHARED_EXAMPLE_GROUPS_END } \
QuickConfigurationEnd
