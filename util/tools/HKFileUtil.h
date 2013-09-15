//
//  FileUtil.h
//  myutil
//
//  Created by 伟 袁 on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKFileUtil : NSObject

+(NSString*)getAppRefPath;

+(NSString*)getFilePath:(NSString*)fileName;

+(BOOL)copyFromResource:(NSString*)resourceFileName absFileName:(NSString*)absFileName;

+(BOOL)isFileExist:(NSString*)absFileName;

@end
