//
//  HKSQLQuery.m
//  hkutil2
//
//  Created by akwei on 13-4-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKSQLQuery.h"
#import "CfgHeader.h"

#define DbConnDebug 0
#define DbConnTrDebug 0
#define _SQL_DEBUG_OPEN 0
#define _SQL_EXCEPTION_OPEN 1
#define SQLExceptionMsg @"database write error"
#define DB_CNF_FILE_NAME @"db_cfg"


static NSMutableDictionary* DbConn_pubDic=nil;
static NSMutableArray* ignoreRollbackExArr=nil;
static NSMutableDictionary *classInfoDic=nil;
static NSMutableDictionary* HKSQLQuery_pubDic=nil;
static NSMutableDictionary* objQueryDic=nil;

#pragma mark - HKSQLException
@implementation HKSQLException
@synthesize status;
@end

#pragma mark - HKClassWrapper
@implementation HKClassWrapper
@end

#pragma mark - HKDbConn

@implementation HKDbConn{
    dispatch_queue_t syncQueue;
    dispatch_queue_t trSyncQueue;
}


+(id)getWithDbName:(NSString *)name{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DbConn_pubDic = [[NSMutableDictionary alloc] init];
    });
    @synchronized(self){
        HKDbConn* con = [DbConn_pubDic valueForKey:name];
        if (!con) {
            con = [[HKDbConn alloc] initWithDbName:name];
            [DbConn_pubDic setValue:con forKey:name];
        }
        return con;
    }
}

+(void)addRollbackIgnoreExceptionCls:(Class)exCls{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignoreRollbackExArr = [[NSMutableArray alloc] init];
    });
    HKClassWrapper* cw = [[HKClassWrapper alloc] init];
    cw.cls=exCls;
    [ignoreRollbackExArr addObject:cw];
}

+(BOOL)hasRollbackIgnoreException:(NSException *)ex{
    for (HKClassWrapper* cw in ignoreRollbackExArr) {
        if ([ex isKindOfClass:cw.cls]) {
            return true;
        }
    }
    return false;
}

-(id)init{
    return nil;
}

-(id)initWithDbName:(NSString *)name{
    self =[ super init];
    if (self) {
        NSString* queue_name = [[NSString alloc] initWithFormat:@"hk_simpleorm_dbconn_syncqueue_%@",name];
        syncQueue = dispatch_queue_create([queue_name UTF8String], DISPATCH_QUEUE_SERIAL);
        NSString* tr_queue_name = [[NSString alloc] initWithFormat:@"%@_tr",queue_name];
        trSyncQueue = dispatch_queue_create([tr_queue_name UTF8String], DISPATCH_QUEUE_SERIAL);
        self.dbName=name;
        hasTranscation=NO;
        dbOpen=NO;
        transcationInvokeCount=0;
        return self;
    }
    return nil;
}

-(void)dealloc{
#if NEEDS_DISPATCH_RETAIN_RELEASE
	if (syncQueue) dispatch_release(syncQueue);
    if (trSyncQueue) dispatch_release(trSyncQueue);
#endif
}


-(sqlite3 *)getDbHandle{
    return dbhandle;
}

+(NSString *)getAppRefPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+(NSString *)getFilePath:(NSString *)fileName{
    return [[self getAppRefPath] stringByAppendingPathComponent:fileName];
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

-(void)open{
    __weak HKDbConn* me = self;
    dispatch_sync(syncQueue, ^{
        @autoreleasepool {
            if (dbOpen) {
                return ;
            }
            NSString* dbPath=[HKDbConn getFilePath:me.dbName];
#if DbConnDebug
            NSLog(@"%@",dbPath);
#endif
            if (![HKDbConn isFileExist:dbPath]) {
                BOOL result = [HKDbConn copyFromResource:me.dbName absFileName:dbPath];
                if (!result) {
                    NSString* exname=[NSString stringWithFormat:@"create db file %@ err",me.dbName];
                    [me throwException:0 exName:exname reason:@""];
                }
            }
            NSInteger stat=sqlite3_open([dbPath UTF8String], &dbhandle);
            if (stat==SQLITE_OK) {
                dbOpen=YES;
                return ;
            }
            NSString* reason=[NSString stringWithUTF8String:sqlite3_errmsg(dbhandle)];
            NSString* exname=[NSString stringWithFormat:@"close db %@ err",me.dbName];
            [me throwException:stat exName:exname reason:reason];
        } 
    });
}

-(void)beginTranscation{
    __weak HKDbConn* me = self;
    dispatch_sync(syncQueue, ^{
        transcationInvokeCount++;
        if (hasTranscation) {
            return ;
        }
        hasTranscation=YES;
        int status=sqlite3_exec(dbhandle, "begin", 0, 0, NULL);
        if (status!=SQLITE_OK) {
            [me throwException:status exName:@"beginTranscation err" reason:@"beginTranscation err"];
        }
    });
}

-(void)commit{
    __weak HKDbConn* me = self;
    dispatch_sync(syncQueue, ^{
        transcationInvokeCount--;
#if DbConnTrDebug
        NSLog(@"transcationInvokeCount-- from commit: %d",transcationInvokeCount);
#endif
        if (transcationInvokeCount>0) {
            return ;
        }
        hasTranscation = NO;
        int status=sqlite3_exec(dbhandle, "commit", 0, 0, NULL);
#if DbConnTrDebug
        NSLog(@"transcation commit");
#endif
        if (status!=SQLITE_OK) {
            [me throwException:status exName:@"commit err" reason:@"commit err"];
        }
    });
}

-(void)rollback{
    __weak HKDbConn* me = self;
    dispatch_sync(syncQueue, ^{
        transcationInvokeCount = 0;
#if DbConnTrDebug
        NSLog(@"transcationInvokeCount-- from rollback: %d",transcationInvokeCount);
#endif
        hasTranscation = NO;
        int status = sqlite3_exec(dbhandle, "rollback", 0, 0, NULL);
        if (status != SQLITE_OK) {
            [me throwException:status exName:@"rollback err" reason:@"rollback err"];
        }
    });
}

-(void)close{
    __weak HKDbConn* me = self;
    dispatch_sync(syncQueue, ^{
        @autoreleasepool {
            if (hasTranscation) {
                return;
            }
#if DbConnDebug
            NSLog(@"connection close");
#endif
            dbOpen = NO;
            int status;
            BOOL retry = NO;
            int retryMaxCount = 3;
            int retryCount = 0;
            do {
                status = sqlite3_close(dbhandle);
                if (status != SQLITE_OK) {
                    retryCount ++;
                    if (retryCount > retryMaxCount) {
                        NSString* reason = [[NSString alloc] initWithUTF8String:sqlite3_errmsg(dbhandle)];
                        NSString* exname = [NSString stringWithFormat:@"close db %@ err",me.dbName];
                        [me throwException:status exName:exname reason:reason];
                        return;
                    }
                    if (status == SQLITE_BUSY || status == SQLITE_LOCKED) {
                        usleep(20);
                        retry = YES;
                        NSLog(@"retry close db %@",me.dbName);
                    }
                }
            } while (retry);
        }
    });
}

-(void)doTranscationWithBlock:(void (^)(void))block{
    __weak HKDbConn* me = self;
    dispatch_sync(trSyncQueue, ^{
        @try {
            [me open];
            [me beginTranscation];
            block();
            [me commit];
        }
        @catch (NSException *exception) {
            if ([HKDbConn hasRollbackIgnoreException:exception]) {
                [me commit];
            }
            else{
                [me rollback];
            }
            @throw exception;
        }
        @finally {
            [me close];
        }
    });
}

-(void)throwException:(NSInteger)status exName:(NSString*)exName reason:(NSString*)reason{
    NSString* errStatus = [NSString stringWithFormat:@"%i : %@",status,reason];
    HKSQLException* ex = [[HKSQLException alloc] initWithName:exName reason:errStatus userInfo:nil];
    ex.status = status;
    NSLog(@"%@",[ex description]);
    @throw ex;
}

@end


#pragma mark - HKClassInfo

@implementation HKClassInfo

+(NSMutableDictionary*)getClassInfoDicInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classInfoDic=[[NSMutableDictionary alloc] init];
    });
    return classInfoDic;
}

+(HKClassInfo *)getClassInfoWithClass:(Class)cls{
    NSString* className=[NSString stringWithCString:class_getName(cls) encoding:NSUTF8StringEncoding];
    return [[HKClassInfo getClassInfoDicInstance] valueForKey:className];
}

+(HKClassInfo*)getClassInfoWithClassName:(NSString*)className{
    NSMutableDictionary* dic=[HKClassInfo getClassInfoDicInstance];
    return [dic valueForKey:className];
}

-(NSString *)getPropNameWithColName:(NSString *)colName{
    return [self.columnPropDic valueForKey:colName];
}

-(id)init{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.propsDic=[NSMutableDictionary dictionary];
        self.columnPropDic=[NSMutableDictionary dictionary];
        self.propsList=[NSMutableArray array];
        self.columnList=[NSMutableArray array];
        self.propTypeEncodingDic=[NSMutableDictionary dictionary];
    }
    return self;
}

-(NSString *)getPropTypeEncoding:(NSString *)propName{
    return [self.propTypeEncodingDic valueForKey:propName];
}
//添加配置中的类property，property和column是一样的
-(void)addPropWithName:(NSString *)name{
    //设置第一个字段为id字段
    if ([self.propsList count]==0) {
        self.idPropName=name;
        self.idColumnName=name;
    }
    id value=[self.propsDic valueForKey:name];
    NSString* columnName=name;
    if (value) {
        [self.propsDic removeObjectForKey:name];
        [self.columnPropDic removeObjectForKey:columnName];
        for (NSString* value in self.propsList) {
            if ([value isEqualToString:name]) {
                [self.propsList removeObject:value];
            }
        }
        for (NSString* value in self.columnList) {
            if ([value isEqualToString:columnName]) {
                [self.columnList removeObject:value];
            }
        }
    }
    [self.propsDic setValue:columnName forKey:name];
    [self.columnPropDic setValue:name forKey:columnName];
    [self.propsList addObject:name];
    [self.columnList addObject:columnName];
}

-(BOOL)hasPropWithName:(NSString *)name{
    if ([self.propsDic valueForKey:name]) {
        return YES;
    }
    return NO;
}

-(void)buildInsertSQL{
    NSMutableString* sql=[[NSMutableString alloc] init];
    [sql appendFormat:@"insert into %@",self.tableName];
    [sql appendString:@"("];
    for (NSString* name in self.columnList) {
        [sql appendFormat:@"%@,",name];
    }
    [sql deleteCharactersInRange:NSMakeRange([sql length]-1, 1)];
    [sql appendString:@") values ("];
    for (int i=0;i<[self.columnList count];i++) {
        [sql appendString:@"?,"];
    }
    [sql deleteCharactersInRange:NSMakeRange([sql length]-1, 1)];
    [sql appendString:@")"];
    self.insertSQL=sql;
}

-(void)buildUpdateSQL{
    NSMutableString* sql=[[NSMutableString alloc] init];
    [sql appendFormat:@"update %@ set ",self.tableName];
    for (NSString* name in self.columnList) {
        [sql appendFormat:@"%@=?,",name];
    }
    [sql deleteCharactersInRange:NSMakeRange([sql length]-1, 1)];
    [sql appendFormat:@" where %@=?",self.idColumnName];
    self.updateSQL=sql;
}

-(void)buildDeleteByIdSQL{
    NSMutableString* sql=[[NSMutableString alloc] init];
    [sql appendFormat:@"delete from %@ where %@=?",self.tableName,self.idColumnName];
    self.deleteByIdSQL=sql;
}

-(void)load{
    [self buildInsertSQL];
    [self buildUpdateSQL];
    [self buildDeleteByIdSQL];
    id MyClass=objc_getClass([self.className UTF8String]);
    Class cls=[MyClass class];
    unsigned int outCount;
    objc_property_t *props=class_copyPropertyList(MyClass, &outCount);
    for (int i=0; i<outCount; i++) {
        objc_property_t prop=props[i];
        const char* propName = property_getName(prop);
        NSString* _propName=[[NSString alloc] initWithUTF8String:propName];
        Ivar ivar=class_getInstanceVariable(cls, propName);
        if (!ivar) {
            NSString* pn=[[NSString alloc] initWithFormat:@"_%@",_propName];
            ivar=class_getInstanceVariable(cls, [pn UTF8String]);
        }
        const char* typeEncoding=ivar_getTypeEncoding(ivar);
        NSString* _typeEncoding=[[NSString alloc] initWithUTF8String:typeEncoding];
        if ([self hasPropWithName:_propName]) {
            [self.propTypeEncodingDic setValue:_typeEncoding forKey:_propName];
        }
    }
    free(props);
}

@end

#pragma mark - HKSQLQuery
@implementation HKSQLQuery{
     dispatch_queue_t syncQueue;
}

+(HKSQLQuery *)sqlQueryWithDbName:(NSString *)dbName{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HKSQLQuery_pubDic = [[NSMutableDictionary alloc] init];
    });
    @synchronized(self){
        HKSQLQuery* query = [HKSQLQuery_pubDic valueForKey:dbName];
        if (!query) {
            query = [[HKSQLQuery alloc] initWithDbName:dbName];
            [HKSQLQuery_pubDic setValue:query forKey:dbName];
        }
        return query;
    }
}

-(id)init{
    return nil;
}

/*
 此方法请在主线程中使用
 */
-(id)initWithDbName:(NSString*)dbName{
    self=[super init];
    if (self) {
        self.dbConn=[HKDbConn getWithDbName:dbName];
        NSString* n = [[NSString alloc] initWithFormat:@"hk_simpleorm_sqlquery2_%@",dbName];
        syncQueue = dispatch_queue_create([n UTF8String], DISPATCH_QUEUE_SERIAL);
        return self;
    }
    return nil;
}

-(void)dealloc{
#if NEEDS_DISPATCH_RETAIN_RELEASE
	if (syncQueue) dispatch_release(syncQueue);
#endif
}

-(NSInteger)insertWithSQL:(NSString *)sql params:(NSArray *)params{
    __block NSInteger lastId;
    dispatch_sync(syncQueue, ^{
        [self execute:sql exeBlock:^(sqlite3_stmt *stmt) {
            [self bindParams:stmt params:params];
            lastId = [self update:stmt findLastInsertId:YES];
        }];
    });
    return lastId;
}

-(void)updateWithSQL:(NSString *)sql params:(NSArray *)params{
    dispatch_sync(syncQueue, ^{
        [self execute:sql exeBlock:^(sqlite3_stmt *stmt) {
            [self bindParams:stmt params:params];
            [self update:stmt findLastInsertId:NO];
        }];
    });
}

-(long long)numberWithSQL:(NSString *)sql params:(NSArray *)params{
    __block long long num=0;
    dispatch_sync(syncQueue, ^{
        [self execute:sql exeBlock:^(sqlite3_stmt *stmt) {
            [self bindParams:stmt params:params];
            while ([self queryNextRow:stmt]) {
                num = sqlite3_column_int64(stmt, 0);
            }
        }];
    });
    return num;
}


-(NSArray *)listWithSQL:(NSString *)sql params:(NSArray *)params{
    __block NSMutableArray* list=[NSMutableArray array];
    dispatch_sync(syncQueue, ^{
        [self execute:sql exeBlock:^(sqlite3_stmt *stmt) {
            [self bindParams:stmt params:params];
            int i=0;
            while ([self queryNextRow:stmt]) {
                NSMutableDictionary* dic = [self mapRowDic:stmt];
                [list addObject:dic];
                i++;
            }
        }];
    });
    return list;
}

-(void)doTranscationWithBlock:(void (^)(void))block{
    [self.dbConn doTranscationWithBlock:block];
}

-(NSInteger)update:(sqlite3_stmt *)stmt findLastInsertId:(BOOL)find{
    int stat = sqlite3_step(stmt);
    if (stat != SQLITE_DONE) {
        NSString* err_msg=[NSString stringWithUTF8String:sqlite3_errmsg([self.dbConn getDbHandle])];
        NSString* reason=[NSString stringWithFormat:@"sqlite3_step : %@",err_msg];
        [self throwException:stat reason:reason];
        return 0;
    }
    NSInteger lastId=0;
    if (find) {
        lastId=sqlite3_last_insert_rowid([self.dbConn getDbHandle]);
    }
    return lastId;
}

-(BOOL)queryNextRow:(sqlite3_stmt *)stmt{
	NSInteger stat=sqlite3_step(stmt);
	if(stat==SQLITE_ROW){
		return YES;
	}
    if (stat==SQLITE_DONE) {
        return NO;
    }
    return NO;
}

-(sqlite3_stmt *)createStmt:(const char *)zSql handle:(sqlite3*)dbhandle{
	sqlite3_stmt *stmt = nil;
	NSInteger sqlite_stat=sqlite3_prepare_v2(dbhandle, zSql, -1, &stmt, NULL);
	if (sqlite_stat != SQLITE_OK) {
        NSString* err_msg=[NSString stringWithUTF8String:sqlite3_errmsg(dbhandle)];
        NSString* sql=[NSString stringWithUTF8String:zSql];
        NSString* reason=[NSString stringWithFormat:@"sql err : %@\nsql : %@",err_msg,sql];
		[self throwException:sqlite_stat reason:reason];
	}
	return stmt;
}

-(void)throwException:(NSInteger)status reason:(NSString*)reason{
    NSString* errStatus=[NSString stringWithFormat:@"%i : %@",status,reason];
    HKSQLException* ex=[[HKSQLException alloc] initWithName:@"sql exception" reason:errStatus userInfo:nil];
    ex.status=status;
    @throw ex;
}

-(void)closeStmt:(sqlite3_stmt *)stmt{
    int status = sqlite3_finalize(stmt);
    if (status != SQLITE_OK) {
        NSString* err_msg=[NSString stringWithUTF8String:sqlite3_errmsg([self.dbConn getDbHandle])];
        NSString* reason=[NSString stringWithFormat:@"sqlite3_finalize : %@",err_msg];
        [self throwException:status reason:reason];
    }
}

-(void)execute:(NSString*)sql exeBlock:(void (^)(sqlite3_stmt*))exeBlock{
    const char* _sql=[sql UTF8String];
    [self.dbConn open];
    sqlite3* dbhandle=[self.dbConn getDbHandle];
    sqlite3_stmt *stmt=nil;
    @try {
        stmt=[self createStmt:_sql handle:dbhandle];
        exeBlock(stmt);
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        if (stmt) {
            [self closeStmt:stmt];
        }
        [self.dbConn close];
    }
}

-(void)bindParams:(sqlite3_stmt *)stmt params:(NSArray *)params{
    if (params) {
        for (int i=0; i<[params count]; i++) {
            [self bindParam:[params objectAtIndex:i] toColumn:i+1 stmt:stmt];
        }
    }
}

- (void)bindParam:(id)obj toColumn:(int)idx stmt:(sqlite3_stmt*)pStmt {
    if ((!obj) || ((NSNull *)obj == [NSNull null])) {
        sqlite3_bind_null(pStmt, idx);
    }
    // FIXME - someday check the return codes on these binds.
    else if ([obj isKindOfClass:[NSData class]]) {
        const void *bytes = [obj bytes];
        if (!bytes) {
            // it's an empty NSData object, aka [NSData data].
            // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
            bytes = "";
        }
        sqlite3_bind_blob(pStmt, idx, bytes, [obj length], SQLITE_TRANSIENT);
    }
    else if ([obj isKindOfClass:[NSDate class]]) {
        sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        
        if (strcmp([obj objCType], @encode(BOOL)) == 0) {
            sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
        }
        else if (strcmp([obj objCType], @encode(int)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        }
        else if (strcmp([obj objCType], @encode(long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        }
        else if (strcmp([obj objCType], @encode(long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongLongValue]);
        }
        else if (strcmp([obj objCType], @encode(float)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj floatValue]);
        }
        else if (strcmp([obj objCType], @encode(double)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        }
        else {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_TRANSIENT);
        }
    }
    else {
        sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_TRANSIENT);
    }
}

-(NSMutableDictionary*)mapRowDic:(sqlite3_stmt *)stmt{
    int colCount=sqlite3_column_count(stmt);
    NSMutableDictionary* dic=[NSMutableDictionary dictionary];
    for (int i=0; i<colCount; i++) {
        NSString* colName=[[NSString alloc] initWithCString:sqlite3_column_name(stmt, i) encoding:NSUTF8StringEncoding];
        int type=sqlite3_column_type(stmt, i);
        id value=nil;
        if (type==SQLITE_INTEGER) {
            value = [NSNumber numberWithLongLong:sqlite3_column_int64(stmt, i)];
        }
        else if (type==SQLITE_FLOAT) {
            value = [NSNumber numberWithDouble:sqlite3_column_double(stmt, i)];
        }
        else if (type==SQLITE_BLOB) {
            const void *bytes=sqlite3_column_blob(stmt, i);
            int size=sqlite3_column_bytes(stmt, i);
            value=[NSData dataWithBytes:bytes length:size];
        }
        else if (type==SQLITE_NULL) {
            value=[NSNull null];
        }
        else {
            value = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding];
        }
        if (value==nil) {
            value=[NSNull null];
        }
        [dic setValue:value forKey:colName];
    }
    return dic;
}

@end

#pragma mark - HKObjQuery

@implementation HKObjQuery

+(HKObjQuery *)instanceWithDbName:(NSString *)dbName{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objQueryDic=[[NSMutableDictionary alloc] init];
    });
    @synchronized(self){
        HKObjQuery* q;
        q=[objQueryDic valueForKey:dbName];
        if (!q) {
            q=[[HKObjQuery alloc] initWithDbName:dbName];
            [objQueryDic setValue:q forKey:dbName];
        }
        return q;
    }
}

-(id)init{
    return nil;
}

-(id)initWithDbName:(NSString *)name{
    self = [super init];
    if (self) {
        self.sqlQuery=[HKSQLQuery sqlQueryWithDbName:name];
        [self buildDbCfgClass];
    }
    return self;
}

-(void)buildDbCfgClass{
    NSString* dbCfgFilePath=[[NSBundle mainBundle] pathForResource:DB_CNF_FILE_NAME ofType:@"plist"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithContentsOfFile:dbCfgFilePath];
    for (NSString* key in dic) {
        HKClassInfo *ci=[[HKClassInfo alloc] init];
        NSString* fields=[dic valueForKey:key];
        ci.className=key;
        ci.tableName=key;
        NSArray* tmparr=[fields componentsSeparatedByString:@","];
        for (NSString* field in tmparr) {
            [ci addPropWithName:field];
        }
        [ci load];
        NSMutableDictionary* classInfoDic=[HKClassInfo getClassInfoDicInstance];
        [classInfoDic setValue:ci forKey:key];
    }
}

-(NSMutableArray*)bindParams:(HKClassInfo*)ci objId:(id)objId forInsert:(BOOL)forInsert{
    NSMutableArray* params=[NSMutableArray array];
    int i=0;
    @try {
        for (NSString* propName in ci.propsList) {
            id value=nil;
            if (forInsert && i==0) {
                value=[objId valueForKey:propName];
                if ([value isKindOfClass:[NSNumber class]] && [value longLongValue]==0) {
                    value=[NSNull null];
                }
            }
            else {
                value=[objId valueForKey:propName];
            }
            if (value==nil) {
                value=[NSNull null];
            }
            [params addObject:value];
            i++;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"bindParams err :%@ ",[exception description]);
        @throw exception;
    }
    return params;
}

-(void)saveObj:(id)objId{
    NSString* className=[NSString stringWithCString:class_getName([objId class]) encoding:NSUTF8StringEncoding];
    HKClassInfo* ci=[HKClassInfo getClassInfoWithClassName:className];
    NSMutableArray* params=[self bindParams:ci objId:objId forInsert:YES];
    NSInteger lastId = [self.sqlQuery insertWithSQL:ci.insertSQL params:params];
    [objId setValue:[NSNumber numberWithInteger:lastId] forKey:ci.idPropName];
}

-(void)updateObj:(id)objId{
    NSString* className=[NSString stringWithCString:class_getName([objId class]) encoding:NSUTF8StringEncoding];
    HKClassInfo* ci=[HKClassInfo getClassInfoWithClassName:className];
    NSMutableArray* params=[self bindParams:ci objId:objId forInsert:NO];
    [params addObject:[objId valueForKey:ci.idPropName]];
    [self.sqlQuery updateWithSQL:ci.updateSQL params:params];
}

-(void)deleteWithClass:(Class)cls idValue:(id)idValue{
    NSString* className = [NSString stringWithCString:class_getName(cls) encoding:NSUTF8StringEncoding];
    HKClassInfo* ci=[HKClassInfo getClassInfoWithClassName:className];
    NSMutableArray* params=[NSMutableArray array];
    [params addObject:idValue];
    [self.sqlQuery updateWithSQL:ci.deleteByIdSQL params:params];
}

-(void)deleteWithClass:(Class)cls where:(NSString *)where params:(NSArray *)params{
    NSString* className = [NSString stringWithCString:class_getName(cls) encoding:NSUTF8StringEncoding];
    HKClassInfo* ci=[HKClassInfo getClassInfoWithClassName:className];
    NSMutableString* sbuf=[[NSMutableString alloc] init];
    [sbuf appendFormat:@"delete from %@",ci.tableName];
    if (where) {
        [sbuf appendFormat:@" where %@",where];
    }
    @try {
        [self.sqlQuery updateWithSQL:sbuf params:params];
    }
    @finally {
        sbuf = nil;
    }
}

-(long long)countWithClass:(Class)cls where:(NSString *)where  params:(NSArray*)params{
    NSString* className = [NSString stringWithCString:class_getName(cls) encoding:NSUTF8StringEncoding];
    HKClassInfo* ci=[HKClassInfo getClassInfoWithClassName:className];
    NSMutableString* sqlbuf=[NSMutableString string];
    [sqlbuf appendFormat:@"select count(*) from %@",ci.tableName];
    if (where) {
        [sqlbuf appendFormat:@" where %@",where];
    }
    return [self.sqlQuery numberWithSQL:sqlbuf params:params];
}

-(NSArray *)listWithClass:(Class)cls where:(NSString *)where params:(NSArray *)params orderBy:(NSString *)orderBy begin:(NSInteger)begin size:(NSInteger)size{
    NSString* className = [NSString stringWithCString:class_getName(cls) encoding:NSUTF8StringEncoding];
    HKClassInfo* ci=[HKClassInfo getClassInfoWithClassName:className];
    NSMutableString* sqlbuf=[NSMutableString string];
    [sqlbuf appendString:@"select "];
    for (NSString* name in ci.columnList) {
        [sqlbuf appendFormat:@"%@,",name];
    }
    [sqlbuf deleteCharactersInRange:NSMakeRange([sqlbuf length]-1, 1)];
    [sqlbuf appendFormat:@" from %@",ci.tableName];
    if (where) {
        [sqlbuf appendFormat:@" where %@",where];
    }
    if (orderBy) {
        [sqlbuf appendFormat:@" order by %@",orderBy];
    }
    if (begin>=0 && size>0) {
        [sqlbuf appendFormat:@" limit %i,%i",begin,size];
    }
    NSMutableArray* list=[NSMutableArray array];
    NSArray* rowList=[self.sqlQuery listWithSQL:sqlbuf params:params];
    for (NSMutableDictionary* dic in rowList) {
        id o=[[NSClassFromString(ci.className) alloc] init];
        for (NSString* colName in dic) {
            NSString* propName=[ci getPropNameWithColName:colName];
            if (!propName) {
                continue;
            }
            NSString* typeEncoding = [ci getPropTypeEncoding:propName];
            id value=[dic valueForKey:colName];
            if (value && value !=[NSNull null] && ![value isEqual:[NSNull null]]) {
                if ([typeEncoding isEqualToString:@"@\"NSDate\""]) {
                    double longtime=[(NSNumber*)value doubleValue];
                    NSDate* date=[NSDate dateWithTimeIntervalSince1970:longtime];
                    [o setValue:date forKey:propName];
                }
                else {
                    [o setValue:value forKey:propName];
                }
                
            }
            
            
        }
        [list addObject:o];
    }
    return list;
}

-(id)objWithClass:(Class)cls idValue:(id)idValue{
    HKClassInfo* ci = [HKClassInfo getClassInfoWithClass:cls];
    NSMutableString* where=[NSMutableString string];
    [where appendFormat:@"%@=?",ci.idColumnName];
    NSMutableArray* params=[NSMutableArray array];
    [params addObject:idValue];
    NSArray* list=[self listWithClass:cls where:where params:params orderBy:nil begin:0 size:1];
    if ([list count]==0) {
        return nil;
    }
    return [list objectAtIndex:0];
}

@end

#pragma mark - NSObject (HKSQLQueryEx)

@implementation NSObject (HKSQLQueryEx)
+(NSString*)currentDbName{
    NSString* className = [[NSString alloc] initWithUTF8String:class_getName([self class])];
    NSString* msg = [NSString stringWithFormat:@"%@ must override this method that return real dbName",className];
    NSLog(@"%@",msg);
    return nil;
}

+(id)objWithIdValue:(id)idValue{
    Class cls=[self class];
    HKObjQuery* query=[HKObjQuery instanceWithDbName:[cls currentDbName]];
    return [query objWithClass:cls idValue:idValue];
}

+(NSArray *)listWithWhere:(NSString *)where params:(NSArray *)params orderBy:(NSString *)orderBy begin:(NSInteger)begin size:(NSInteger)size{
    Class cls=[self class];
    HKObjQuery* query=[HKObjQuery instanceWithDbName:[cls currentDbName]];
    return [query listWithClass:cls where:where params:params orderBy:orderBy begin:begin size:size];
}

+(id)objWithWhere:(NSString *)where params:(NSArray *)params orderBy:(NSString *)orderBy{
    NSArray* list = [self listWithWhere:where params:params orderBy:orderBy begin:0 size:1];
    if ([list count]==0) {
        return nil;
    }
    return [list objectAtIndex:0];
}

+(NSInteger)countWithWhere:(NSString *)where params:(NSMutableArray *)params{
    Class cls=[self class];
    HKObjQuery* query=[HKObjQuery instanceWithDbName:[cls currentDbName]];
    return [query countWithClass:cls where:where params:params];
}

+(void)updateBySQL:(NSString *)sql params:(NSArray *)params{
    Class cls=[self class];
    HKObjQuery* query=[HKObjQuery instanceWithDbName:[cls currentDbName]];
    [query.sqlQuery updateWithSQL:sql params:params];
}

+(void)updateBySQLSeg:(NSString *)sqlSeg params:(NSArray *)params{
    Class cls=[self class];
    NSString* className=[NSString stringWithCString:class_getName(cls) encoding:NSUTF8StringEncoding];
    HKClassInfo* ci=[HKClassInfo getClassInfoWithClassName:className];
    NSMutableString* sbuf=[[NSMutableString alloc] init];
    [sbuf appendFormat:@"update %@ %@",ci.tableName,sqlSeg];
    @try {
        [self updateBySQL:sbuf params:params];
    }
    @finally {
        sbuf = nil;
    }
}

+(void)deleteWithWhere:(NSString *)where params:(NSArray *)params{
    Class cls=[self class];
    HKObjQuery* query=[HKObjQuery instanceWithDbName:[cls currentDbName]];
    [query deleteWithClass:cls where:where params:params];
}

-(void)saveObj{
    Class cls=[self class];
    HKObjQuery* query=[HKObjQuery instanceWithDbName:[cls currentDbName]];
    [query saveObj:self];
}

-(void)updateObj{
    Class cls=[self class];
    HKObjQuery* query=[HKObjQuery instanceWithDbName:[cls currentDbName]];
    [query updateObj:self];
}

-(void)deleteObj{
    Class cls=[self class];
    HKObjQuery* query=[HKObjQuery instanceWithDbName:[cls currentDbName]];
    HKClassInfo* ci=[HKClassInfo getClassInfoWithClass:cls];
    id idValue= [self valueForKey:ci.idPropName];
    [query deleteWithClass:cls idValue:idValue];
}

@end

