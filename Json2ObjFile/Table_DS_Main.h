//
//  Table_DS_Main.h
//  Json2ObjFile
//
//  Created by ylang on 14-7-9.
//  Copyright (c) 2014年 YunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Table_DS_Main;
@protocol SelectMainDelegate <NSObject>
- (void)request:(Table_DS_Main *)main requestWithHeadDic:(NSDictionary *)headDic bodyDic:(NSDictionary *)bodyDic;
@end

@interface Table_DS_Main : NSObject
@property (nonatomic, weak) id <SelectMainDelegate> mainDeletate;

@property (nonatomic, assign) ParamsEnum paramsType;

@property (weak) IBOutlet NSTableView *tableView;
- (IBAction)request:(id)sender;
@end
