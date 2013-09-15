//
//  FileUtil.m
//  myutil
//
//  Created by 伟 袁 on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HKFileUtil.h"

@implementation HKFileUtil

+(NSString *)getAppRefPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+(NSString *)getFilePath:(NSString *)fileName{
    return [[HKFileUtil getAppRefPath] stringByAppendingPathComponent:fileName];
}

+(BOOL)copyFromResource:(NSString *)resourceFileName absFileName:(NSString *)absFileName{
    NSString *riginFile = [[NSBundle mainBundle] pathForResource:resourceFileName ofType:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL result = [fileManager copyItemAtPath:riginFile toPath:absFileName error:&error];
    if (!result) {
        NSLog(@"%@",error);
        NSLog(@"%@",[error description]);
    }
    return result;
}

+(BOOL)isFileExist:(NSString *)absFileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:absFileName];
}

@end
