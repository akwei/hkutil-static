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

+(NSString*)integerToStringValue:(NSInteger)n;

+(NSString*)integerAddString:(NSString*)str :(NSInteger)n;

+(NSInteger)randNSInteger;

+(NSInteger)randNSInteger:(NSInteger)from to:(NSInteger)to;

+(BOOL)parseBool:(NSString*)value;

+(NSNumber*) parseNumber:(id)value;

+(NSString*) formatNumber:(NSNumber*)n format:(NSString*)format;

@end
