//
//  HKGridOrderTableView.h
//  hk_restaurant2
//
//  Created by akwei on 13-6-20.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HKGridTableView;
@class HKGridTableViewCell;

@protocol HKGridTableViewDelegate <NSObject>
@optional
//section数量
-(NSInteger)numberOfSectionsInGridTableView:(HKGridTableView *)tableView;
@required
//获得section中数据总数
-(NSInteger)gridTableView:(HKGridTableView *)tableView dataCountInSection:(NSInteger)section;
//获得section中每行显示几个单元格
-(NSInteger)gridTableView:(HKGridTableView *)tableView gridCountPerRowInSection:(NSInteger)section;
/**
 获得section中数据数组下标的单元格中的view
 @param tableView 当前table
 @param cell 当前获得的UITableViewCell
 @param section 当前section
 @param rowIndex 当前row中单元格的下标
 @param dataIndex 数据数组的下标
 **/
-(UIView*)gridTableView:(HKGridTableView *)tableView viewForCell:(HKGridTableViewCell*)cell section:(NSInteger)section indexInRow:(NSInteger)rowIndex dataIndex:(NSInteger)dataIndex;
//获得section中每行的高度
-(CGFloat)gridTableView:(HKGridTableView *)tableView heightForRowInSection:(NSInteger)section atDataIndexes:(NSArray*)dataIndexes;
@end

@interface HKGridTableViewCell : UITableViewCell

-(id)viewForIndex:(NSInteger)index;
@end

@interface HKGridTableView : UITableView<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,assign)id<HKGridTableViewDelegate> gridTableViewDelegate;
@end
