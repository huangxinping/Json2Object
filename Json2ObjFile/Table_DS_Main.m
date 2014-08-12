//
//  Table_DS_Main.m
//  Json2ObjFile
//
//  Created by ylang on 14-7-9.
//  Copyright (c) 2014年 YunFeng. All rights reserved.
//

#import "Table_DS_Main.h"
#import "ParamsModel.h"

@interface Table_DS_Main () <NSTableViewDataSource, NSTableViewDelegate>
{
	NSMutableArray *postArray;
}
@end

@implementation Table_DS_Main

- (instancetype)init {
	self = [super init];
	if (self) {
		postArray = [[NSMutableArray alloc] init];
        //        [self.tableView setGridStyleMask:NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask];
        //        //线条色
        //        [self.tableView setGridColor:[NSColor redColor]];
        //        //设置背景色
        //        [self.tableView setBackgroundColor:[NSColor greenColor]];
        //        //设置每个cell的换行模式，显不下时用...
        //        [[self.tableView cell]setLineBreakMode:NSLineBreakByTruncatingTail];
        //        [[self.tableView cell]setTruncatesLastVisibleLine:YES];
	}
	return self;
}

//9 403 730 170


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
	return [postArray count];
}
/* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
 */
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    //	NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0], NSFontAttributeName, nil];
    //    NSLog(@"****************%ld",rowIndex);
	ParamsModel *model = (ParamsModel *)[postArray objectAtIndex:rowIndex];
    
    
	if ([aTableColumn.identifier isEqualTo:@"KeyName"])
		return model.key;
	else
		return model.value;
    //    return @"";
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	ParamsModel *model = [postArray objectAtIndex:row];
    
	if ([tableColumn.identifier isEqualTo:@"KeyName"]) {
		model.key = object;
	}
	else {
		model.value = object;
	}
	NSLog(@"objet--->%@", object);
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    //    NSTableColumn *column = [[self.tableView tableColumns] objectAtIndex:0];
    //    if ([column.identifier  isEqualTo:@"KeyName"])
    //    {
    //
    //    }
    //
    //    NSCell *dycell = [self.tableView preparedCellAtColumn:1 row:0];
    //
    //    NSLog(@"============%@",dycell.title);
    //
    //    NSLog(@"===============%@",[self.tableView tableColumns]);
    //    NSArray *array = [self.tableView tableColumns];
    //    for (NSTableColumn *cell in array)
    //    {
    //        NSLog(@"%@",cell.identifier);
    //    }
    //
    //    NSLog(@"======%ld=====%ld",self.tableView.selectedRow,self.tableView.selectedColumn);
    
    //    NSLog(@"===========%@",[notification userInfo]);
    
    
	NSInteger row;
	row = [self.tableView selectedRow];
    
	NSLog(@"%ld***********", row);
	if (row == -1) {
        //        NSLog(@"........");
	}
	else {
        //        NSLog(@"$$$$$$$$$$$$$$");
	}
}

- (IBAction)addPostValueClick:(id)sender {
	NSLog(@"*****************");
	[self.tableView beginUpdates];
	ParamsModel *params = [[ParamsModel alloc] init];
    params.paramsType = self.paramsType;
    if (params.paramsType == ParamsBody)
    {
        params.key = @"BodyKey";
        params.value = @"BodyValue";
    }
    else
    {
    	params.key = @"HeadKey";
        params.value = @"HeadValue";
    }

	[postArray addObject:params];
    
	[self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[postArray count]] withAnimation:NSTableViewAnimationEffectFade];
	[self.tableView endUpdates];
}

- (IBAction)deletePostValueClick:(id)sender {
	if ([postArray count] == 0) {
		return;
	}
	[self.tableView beginUpdates];
	[postArray removeLastObject];
    
	[self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:[postArray count]] withAnimation:NSTableViewAnimationEffectFade];
	[self.tableView endUpdates];
}

- (void)tableViewSelectionIsChanging:(NSNotification *)notification {
}

- (IBAction)request:(id)sender {
	NSLog(@"...............");
	NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];

	for (int i = 0; i < [postArray count]; i++) {
		ParamsModel *params = [postArray objectAtIndex:i];
        if (params.paramsType == ParamsHead)
        {
            [headDic setValue:params.value forKeyPath:params.key];
        }
        else
        {
            [bodyDic setValue:params.value forKeyPath:params.key];
        }
    }
    
	if (_mainDeletate && [_mainDeletate respondsToSelector:@selector(request:requestWithHeadDic:bodyDic:)]) {
		[_mainDeletate request:self requestWithHeadDic:headDic bodyDic:bodyDic];
	}
}

@end
