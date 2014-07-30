//
//  StringUtil.h
//  huoku_paidui
//
//  Created by akwei on 12-7-27.
//
//

#import <Foundation/Foundation.h>

@interface HKDataUtil : NSObject

+(NSString*)trim:(NSString*)str;

+(NSString*)encodeURL:(NSString *)string;

+(NSString *)decodeURL: (NSString *) input;

+(NSString *)integerToString:(NSInteger)n;

+(NSString *)uintegerToString:(NSUInteger)n;

+(NSString*)doubleToString:(double)value;

+(NSInteger)randNSInteger;

+(NSInteger)randNSInteger:(NSInteger)from to:(NSInteger)to;

+(BOOL)parseBool:(NSString*)value;

+(NSNumber*) parseNumber:(id)value;

+(NSString*) formatNumber:(NSNumber*)n format:(NSString*)format;

+(BOOL)isEmpty:(NSString*)str;

//double类型四舍五入
+(NSDecimalNumber*)doubleRound:(double)value scale:(short)scale roundingMode:(NSRoundingMode)roundingMode;

+(BOOL)isArray:(id)obj;

+(BOOL)isDictionary:(id)obj;

/**
 获得字节数据指定位的数据
 @param bitIndex
 */
+(NSInteger)getBit:(NSInteger)bitIndex fromByte:(char)byte;

@end
