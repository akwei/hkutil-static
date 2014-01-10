//
//  HKTableViewCell.h
//  hkutil-static
//
//  Created by akwei on 13-11-7.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKTableViewCell : UITableViewCell
@property(nonatomic,strong)void (^onSelectedCall)(UITableView* tableView,NSIndexPath* indexPath);

/**
 set一个对象到dictionary中
 @param obj 对象
 @param key key
 */
-(void)setObject:(id)obj forKey:(NSString*)key;

/**
 在 dictionary 中查找一个对象
 @param key key
 */
-(id)objectForKey:(NSString*)key;
@end
