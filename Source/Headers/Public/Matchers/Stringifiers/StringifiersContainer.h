#ifdef __cplusplus

#import <vector>
#import <map>
#import <set>

namespace Cedar { namespace Matchers { namespace Stringifiers {
    namespace {
        template <typename Container>
        NSString * comma_and_newline_delimited_list(const Container & container) {
            NSMutableString *result = [NSMutableString string];
            bool first = true;
            for (typename Container::const_iterator i = container.begin(); i != container.end(); ++i, first = false) {
                if (!first) {
                    [result appendString:@","];
                }

                NSString * string = string_for(*i);
                [result appendString:[NSString stringWithFormat:@"\n    %@", string]];
            }
            return result;
        }
    }

    template<typename T>
    NSString * string_for(const typename std::vector<T> & container) {
        NSString * delimitedList = comma_and_newline_delimited_list(container);
        return [NSString stringWithFormat:@"(%@\n)", delimitedList];
    }

    template<typename T, typename U>
    NSString * string_for(const typename std::map<T, U> & container) {
        NSMutableString *result = [NSMutableString stringWithString:@"{"];

        for (typename std::map<T, U>::const_iterator i = container.begin(); i != container.end(); ++i) {
            NSString * keyString = string_for(i->first);
            NSString * valueString = string_for(i->second);
            [result appendString:[NSString stringWithFormat:@"\n    %@ = %@;", keyString, valueString]];
        }
        [result appendString:@"\n}"];
        return result;
    }

    template<typename T>
    NSString * string_for(const typename std::set<T> & container) {
        NSString * delimitedList = comma_and_newline_delimited_list(container);
        return [NSString stringWithFormat:@"{(%@\n)}", delimitedList];
    }
}}}

#endif // __cplusplus
