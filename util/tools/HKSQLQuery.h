//
//  HKSQLQuery.h
//  hkutil2
//
//  Created by akwei on 13-4-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

/*
 使用方式1:
 HKSQLQuery* query = [HKSQLQuery sqlQueryWithDbName:@"hkutil2.sqlite"];
 Person* obj = [[Person alloc] init];
 obj.name =@"akweiweiwei";
 obj.createtime = [HKTimeUtil nowDoubleDate];
 NSString* text = @"我来测试看看有没有问题    对了    aaa bbb";
 obj.data = [text dataUsingEncoding:NSUTF8StringEncoding];
 obj.pid = [query insertWithSQL:@"insert into Person(pid,name,data,createtime) values(?,?,?,?)"
 params:@[[NSNull null],obj.name,obj.data,[NSNumber numberWithDouble:obj.createtime]]];
 NSLog(@"insert person pid : %llu",(unsigned long long)obj.pid);
 
 [query updateWithSQL:@"update Person set name=? where pid=?" params:@[@"apple",[NSNumber numberWithUnsignedInteger:obj.pid]]];
 
 NSInteger count = [query countWithSQL:@"select count(*) from Person" params:nil];
 NSLog(@"current count : %lu",(unsigned long)count);
 
 NSArray* list = [query listWithSQL:@"select * from Person" params:nil];//NSDictonary in list
 if ([list count]!=count) {
 NSLog(@"select count not equal list size");
 }
 
 [query updateWithSQL:@"delete from Person where pid=?" params:@[[NSNumber numberWithUnsignedInteger:obj.pid]]];
 
 使用方式2:
 
 */

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <sqlite3.h>

@interface HKClassWrapper : NSObject
@property(nonatomic,assign)Class cls;
@end

@interface HKSQLException : NSException
@property(nonatomic,assign)NSInteger status;
@end

@interface HKDbConn : NSObject{
    sqlite3* dbhandle;
    BOOL hasTranscation;
    BOOL dbOpen;
    NSInteger transcationInvokeCount;
}

@property(nonatomic,copy)NSString* dbName;

+(id)getWithDbName:(NSString*)name;
/*
 添加遇到的指定异常可不回滚事务，默认所有异常都需要回滚
 */
+(void)addRollbackIgnoreExceptionCls:(Class)exCls;
-(sqlite3*)getDbHandle;
-(void)open;
-(void)beginTranscation;
-(void)commit;
-(void)rollback;
-(void)close;
-(void)doTranscationWithBlock:(void(^)(void))block;

@end

@interface HKClassInfo : NSObject

@property(nonatomic,copy) NSString* className;
@property(nonatomic,copy) NSString* tableName;
@property(nonatomic,copy) NSString* idPropName;
@property(nonatomic,copy) NSString* idColumnName;
@property(nonatomic,strong) NSMutableArray* propsList;//存储对象属性
@property(nonatomic,strong) NSMutableArray* columnList;//存储sql中的列
@property(nonatomic,strong) NSMutableDictionary* propsDic;//property : column
@property(nonatomic,strong) NSMutableDictionary* columnPropDic;//column : property
@property(nonatomic,strong) NSMutableDictionary* propTypeEncodingDic;
@property(nonatomic,copy) NSString* insertSQL;
@property(nonatomic,copy) NSString* updateSQL;
@property(nonatomic,copy) NSString* deleteByIdSQL;

+(HKClassInfo*)getClassInfoWithClassName:(NSString*)className;
+(NSMutableDictionary*)getClassInfoDicInstance;
+(HKClassInfo*)getClassInfoWithClass:(Class)cls;
-(BOOL)hasPropWithName:(NSString*)name;
-(void)load;
-(void)addPropWithName:(NSString*)name;
-(NSString*)getPropTypeEncoding:(NSString*)propName;
-(NSString*)getPropNameWithColName:(NSString*)colName;

@end

@interface HKSQLQuery : NSObject

@property(nonatomic,strong)HKDbConn* dbConn;

/*
 通过dbName获得SQLQuery对象
 */
+(HKSQLQuery*)sqlQueryWithDbName:(NSString*)dbName;

/*
 insert
 @param sql sql语句
 @param params 绑定sql中带有'?'的参数，顺序要与sql中'?'的顺序对应
 */
-(NSInteger)insertWithSQL:(NSString*)sql params:(NSArray*)params;

/*
 update
 @param sql sql语句
 @param params 绑定sql中带有'?'的参数，顺序要与sql中'?'的顺序对应
 */
-(void)updateWithSQL:(NSString*)sql params:(NSArray*)params;

/*
 select 获得整型数字
 @param sql sql语句
 @param params 绑定sql中带有'?'的参数，顺序要与sql中'?'的顺序对应
 */
-(long long)numberWithSQL:(NSString*)sql params:(NSArray*)params;

/*
 select
 @param sql sql语句
 @param params 绑定sql中带有'?'的参数，顺序要与sql中'?'的顺序对应
 */
-(NSArray*)listWithSQL:(NSString*)sql params:(NSArray*)params;

/*
 进行事务方式的操作
 */
-(void)doTranscationWithBlock:(void (^)(void))block;

@end

@interface HKObjQuery : NSObject

@property(nonatomic,strong) HKSQLQuery* sqlQuery;

+(HKObjQuery*)instanceWithDbName:(NSString*)dbName;

//inset 对象
-(void)saveObj:(id)objId;

//update 对象
-(void)updateObj:(id)objId;

//delete 对象
-(void)deleteWithClass:(Class)cls idValue:(id)idValue;

-(void)deleteWithClass:(Class)cls where:(NSString*)where params:(NSArray*)params;

//select count(*)统计
-(long long)countWithClass:(Class)cls where:(NSString *)where params:(NSArray*)params;

//select * from table 获取cls类型对象集合
-(NSArray*)listWithClass:(Class)cls where:(NSString*)where params:(NSArray*)params orderBy:(NSString*)orderBy begin:(NSInteger)begin size:(NSInteger)size;

-(id)objWithClass:(Class)cls idValue:(id)idValue;


@end

@interface NSObject (HKSQLQueryEx)
//子类必须重写此方法，返回真实的数据库文件名称
+(NSString*)currentDbName;
/*
 通过唯一id获得数据对象
 */
+(id)objWithIdValue:(id)idValue;

/*
 通过条件查询获得对象数组
 @param where where sql
 @param params 绑定sql中带有'?'的参数，顺序要与sql中'?'的顺序对应
 @param orderBy 排序sql
 @param begin 获取数据开始位置
 @param size 获取数据数量
 */
+(NSMutableArray*)listWithWhere:(NSString*)where params:(NSArray*)params orderBy:(NSString*)orderBy begin:(NSInteger)begin size:(NSInteger)size;

/*
 通过条件获得对象
 @param where where sql
 @param params 绑定sql中带有'?'的参数，顺序要与sql中'?'的顺序对应
 @param orderBy 排序sql
 */
+(id)objWithWhere:(NSString*)where params:(NSArray*)params orderBy:(NSString*)orderBy;

/*
 获得统计数量
 @param where where sql
 @param params 绑定sql中带有'?'的参数，顺序要与sql中'?'的顺序对应
 */
+(NSInteger)countWithWhere:(NSString*)where params:(NSArray*)params;

/*
 使用完整sql更新数据
 */
+(void)updateBySQL:(NSString*)sql params:(NSArray*)params;

/*
 使用sql片段更新数据.例: updateBySQLSeg:@"set name=? where uid=?" params:params;
 */
+(void)updateBySQLSeg:(NSString*)sqlSeg params:(NSArray*)params;

/*
 删除数据
 @param where where sql
 @param params 绑定sql中带有'?'的参数，顺序要与sql中'?'的顺序对应
 */
+(void)deleteWithWhere:(NSString*)where params:(NSArray*)params;

/*
 保存对象
 */
-(void)saveObj;

/*
 更新对象
 */
-(void)updateObj;

/*
 删除对象
 */
-(void)deleteObj;
@end