//
//  HKGridOrderTableView.m
//  hk_restaurant2
//
//  Created by akwei on 13-6-20.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKGridTableView.h"
#import "HKPageHelper.h"

@interface HKGridTableViewCell ()
//单元格view数组,当UITableViewCell重用时,数组中的view也可以重用
@property(nonatomic,strong)NSMutableArray* gridViewList;
@end

@implementation HKGridTableViewCell
-(id)viewForIndex:(NSInteger)index{
    if (index>-1 && index < [self.gridViewList count]) {
        return [self.gridViewList objectAtIndex:index];
    }
    return nil;
}
@end

@implementation HKGridTableView{
    HKPageHelper* _pageHelper;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.gridTableViewDelegate && [self.gridTableViewDelegate respondsToSelector:@selector(numberOfSectionsInGridTableView:)]) {
        [self.gridTableViewDelegate numberOfSectionsInGridTableView:self];
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.gridTableViewDelegate) {
        return 0;
    }
    _pageHelper = [[HKPageHelper alloc] init];
    NSInteger dataCount = [self.gridTableViewDelegate gridTableView:self dataCountInSection:section];
    NSInteger size = [self.gridTableViewDelegate gridTableView:self gridCountPerRowInSection:section];
    [_pageHelper buildWithDataCount:dataCount size:size];
    return _pageHelper.totalPage;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    [_pageHelper changePage:indexPath.row + 1];
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (int i=_pageHelper.begin; i <= _pageHelper.end; i++) {
        [list addObject:[NSNumber numberWithInt:i]];
    }
    return [self.gridTableViewDelegate gridTableView:self heightForRowInSection:indexPath.section atDataIndexes:list];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cid = @"grid_cell";
    HKGridTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cid];
    if (!cell) {
        cell = [[HKGridTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
        cell.gridViewList = [[NSMutableArray alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [_pageHelper changePage:indexPath.row + 1];
    int k=0;
    if (_pageHelper.begin<0) {
        NSLog(@"_pageHelper.begin %d < 0",_pageHelper.begin);
    }
    if (_pageHelper.begin<0) {
        NSLog(@"_pageHelper.end %d < 0",_pageHelper.end);
    }
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (int i=_pageHelper.begin; i <= _pageHelper.end; i++,k++) {
        UIView* view = [self.gridTableViewDelegate gridTableView:self viewForCell:cell section:indexPath.section indexInRow:k dataIndex:i];
        [list addObject:view];
    }
    for (UIView* view in cell.gridViewList) {
        [view removeFromSuperview];
    }
    [cell.gridViewList removeAllObjects];
    CGFloat x = 0;
    for (UIView* view in list) {
        CGRect frame = view.frame;
        frame.origin.x = x;
        view.frame = frame;
        [cell addSubview:view];
        [cell.gridViewList addObject:view];
        x = x + frame.size.width;
    }
    return cell;
}




@end
