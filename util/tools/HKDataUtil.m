//
//  StringUtil.m
//  huoku_paidui
//
//  Created by akwei on 12-7-27.
//
//

#import "HKDataUtil.h"

@implementation HKDataUtil


+(NSString *)trim:(NSString *)str{
    return  [str stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString*)encodeURL:(NSString *)string
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (__bridge CFStringRef)string,
                                                                                                    NULL,
                                                                                                    //                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    (CFStringRef)@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`",
                                                                                                    kCFStringEncodingUTF8 ));
    return encodedString;
}

+ (NSString *)decodeURL: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(NSString *)integerToStringValue:(NSInteger)n{
    return [[NSNumber numberWithLongLong:n] stringValue];
}

+(NSString *)integerAddString:(NSString *)str :(NSInteger)n{
    return [NSString stringWithFormat:@"%@%i",str,n];
}


/*
 有时候我们需要在程序中生成随机数，但是在Objective-c中并没有提供相应的函数，好在C中提供了rand()、srand()、random()、arc4random()几个函数。那么怎么使用呢？下面将简单介绍：
 使用
 1、  获取一个随机整数范围在：[0,100)包括0，不包括100
 int x = arc4random() % 100;
 2、  获取一个随机数范围在：[500,1000），包括500，不包括1000
 int y = (arc4random() % 501) + 500;
 3、  获取一个随机整数，范围在[from,to），包括from，不包括to
 -(int)getRandomNumber:(int)from to:(int)to
 {
 return (int)(from + (arc4random() % (to – from + 1)));
 }
 */

+(NSInteger)randNSInteger{
    return arc4random();
}

+(NSInteger)randNSInteger:(NSInteger)from to:(NSInteger)to{
    return (int)(from + (arc4random()%(to-from+1)));
}

+(BOOL)parseBool:(NSString *)value{
    if (value) {
        if ([[value lowercaseString] isEqualToString:@"true"]) {
            return YES;
        }
        return NO;
    }
    return NO;
}

+(NSNumber *)parseNumber:(id)value{
    if (value) {
        return (NSNumber*)value;
    }
    return [NSNumber numberWithInt:0];
}

+(NSString *)formatNumber:(NSNumber *)n format:(NSString *)format{
    NSNumberFormatter* fmt = [[NSNumberFormatter alloc] init];
    fmt.positiveFormat = format;
    fmt.roundingMode = NSNumberFormatterRoundFloor;
    return [fmt stringFromNumber:n];
}

+(BOOL)isEmpty:(NSString *)str{
    if (!str) {
        return YES;
    }
    if ([[self trim:str] length] == 0) {
        return YES;
    }
    return NO;
}

+(NSDecimalNumber*)doubleRound:(double)value scale:(short)scale roundingMode:(NSRoundingMode)roundingMode{
    NSDecimalNumberHandler* handler = [[NSDecimalNumberHandler alloc] initWithRoundingMode:roundingMode scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber* _num = [[NSDecimalNumber alloc] initWithDouble:value];
    NSDecimalNumber* result = [_num decimalNumberByRoundingAccordingToBehavior:handler];
    return result;
}

+(BOOL)isArray:(id)obj{
    if ([obj isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return NO;
}

+(BOOL)isDictionary:(id)obj{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    return NO;
}

@end
