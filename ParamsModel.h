//
//  PostModel.h
//  Json2ObjFile
//
//  Created by ylang on 14-7-10.
//  Copyright (c) 2014年 YunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParamsModel : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) ParamsEnum paramsType;
@end
