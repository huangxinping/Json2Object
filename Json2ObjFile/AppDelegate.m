//
//  AppDelegate.m
//  Json2ObjFile
//
//  Created by zz on 14-6-23.
//  Copyright (c) 2014年 YunFeng. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONKit.h"
#import "AFHTTPRequestOperationManager.h"
@interface AppDelegate();

@end

@implementation AppDelegate




- (id)init {
	if ((self = [super init])) {
       
	}
	return self;
}


- (IBAction)touchRequestType:(id)sender
{
    self.type = self.requesetType.indexOfSelectedItem;
    NSLog(@"=====%ld",self.requesetType.indexOfSelectedItem);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    

    self.mainController.mainDeletate = self;
    [self createInitfile];
    self.type = RequestENUMGet;
	[self.textClass setStringValue:@"DSInfoManager"];
	[self.textView setString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
}

- (void)createInitfile
{
    if (!fileManager)
    {
        fileManager = [NSFileManager defaultManager];
    }
    
}

-(NSString *)localDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,                                                                          NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *localPath = [NSString stringWithFormat:@"%@/modelManager",documentsDirectory];
    
    
    NSError *error;
    
    if ([fileManager fileExistsAtPath:localPath])
    {
//        NSLog(@"已经存在");
    }else
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return  localPath;
}
- (NSString *)parse:(NSDictionary *)dictionary className:(NSString *)classname {
	NSArray *keyArray = [dictionary allKeys];
	NSString *fileStr = [NSString stringWithFormat:@"\r\n\r\n@interface %@ : NSObject \r\n\r\n", classname];

	for (int i = 0; i < keyArray.count; i++) {
		NSString *key = [keyArray objectAtIndex:i];
		id value = [dictionary objectForKey:key];
		if ([value isKindOfClass:[NSString class]]) {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSString *%@;\r\n", fileStr, key];
		}
		else if ([value isKindOfClass:[NSNumber class]]) {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSNumber *%@;\r\n", fileStr, key];
		}
		else if ([value isKindOfClass:[NSArray class]]) {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSArray *%@;\r\n", fileStr, key];
			if ([(NSArray *)value count] &&
			    [[(NSArray *)value objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
				[self parse:[(NSArray *)value objectAtIndex : 0] className:[NSString stringWithFormat:@"DS%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]]];
			}
		}
		else if ([value isKindOfClass:[NSDictionary class]]) {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSDictionary *%@;\r\n", fileStr, key];
			[self parse:value className:[NSString stringWithFormat:@"DS%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]]];
		}
		else if ([value isKindOfClass:[NSNull class]]) {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSNull *%@;\r\n", fileStr, key];
		}
	}

	fileStr = [fileStr stringByAppendingString:@"\r\n@end"];

    NSString *head = [NSString stringWithFormat:@"\r\n#import <Foundation/Foundation.h>"];
    
    fileStr = [head stringByAppendingString:fileStr];
    NSError *error;
    NSString *filePath = [NSString stringWithFormat:@"%@.h",classname];
    
    NSString *filePath2 = [[self localDocumentsDirectory] stringByAppendingPathComponent:filePath];
    if ([fileStr writeToFile:filePath2 atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
//      NSLog(@"************%@",[fileManager contentsOfDirectoryAtPath:localPath error:&error]);
//        NSLog(@"创建成功");
    }else
    {
       NSLog(@"************%@",error);
    }
    
     NSString *classhead = [NSString stringWithFormat:@"\r#import \"%@\"\r",filePath];
    
    fileStr = [NSString stringWithFormat:@"%@\r%@",fileStr,classhead];
	fileStr = [NSString stringWithFormat:@"%@\r\n\r\n@implementation %@\r\n", fileStr, classname];
	fileStr = [NSString stringWithFormat:@"%@\r\n- (id)init {", fileStr];
	fileStr = [NSString stringWithFormat:@"%@\r\n    if ((self = [super init])) {", fileStr];
	fileStr = [NSString stringWithFormat:@"%@\r\n   }", fileStr];
	fileStr = [NSString stringWithFormat:@"%@\r\n   return self;", fileStr];
	fileStr = [NSString stringWithFormat:@"%@\r\n}\r\n", fileStr];

	fileStr = [fileStr stringByAppendingString:@"\r\n@end"];

    NSString  *classfileStr = [NSString stringWithFormat:@"\r\n\r\n@implementation %@\r\n", classname];
	classfileStr = [NSString stringWithFormat:@"%@\r\n- (id)init {", classfileStr];
	classfileStr = [NSString stringWithFormat:@"%@\r\n    if ((self = [super init])) {", classfileStr];
	classfileStr = [NSString stringWithFormat:@"%@\r\n   }", classfileStr];
	classfileStr = [NSString stringWithFormat:@"%@\r\n   return self;", classfileStr];
	classfileStr = [NSString stringWithFormat:@"%@\r\n}\r\n", classfileStr];
    classfileStr = [NSString stringWithFormat:@"%@\r\n\r@end", classfileStr];
    
    
    NSString *classfilePath = [NSString stringWithFormat:@"%@.m",classname];
   
    classfileStr = [classhead stringByAppendingString:classfileStr];
    
    NSString *classfilePath2 = [[self localDocumentsDirectory] stringByAppendingPathComponent:classfilePath];
    
    
    if ([classfileStr writeToFile:classfilePath2 atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
//        NSLog(@"************%@",[fileManager contentsOfDirectoryAtPath:[self localDocumentsDirectory] error:&error]);
    }else
    {
        NSLog(@"************%@",error);
    }
	[self.outputTextView setString:[NSString stringWithFormat:@"%@%@", self.outputTextView.string, fileStr]];
	return fileStr;
}

- (IBAction)touchCreateFile:(id)sender {
    
    NSError *error;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:[self localDocumentsDirectory] error:&error];
    for (NSString *file in files)
    {
        [fileManager removeItemAtPath:[[self localDocumentsDirectory] stringByAppendingString:file] error:&error];
    }
	NSString *jsonStr = self.textView.textStorage.string;

	NSDictionary *dic = [self GetDictionaryWithJson:jsonStr];
	if (dic == nil) {
//		self.textView.string = @"JSON格式错误";
		NSAlert *alert = [NSAlert alertWithError:[NSError errorWithDomain:@"JSON格式错误" code:500 userInfo:nil]];
		[alert runModal];
		return;
	}

	[self.outputTextView setString:@""];
	[self parse:dic className:self.textClass.stringValue];
}

- (NSDictionary *)GetDictionaryWithJson:(NSString *)jsonStr {
	return [jsonStr objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
}

- (IBAction)requestButtonClicked:(id)sender {
	if ([self.requestTextField.stringValue length] <= 0) {
		return;
	}
    
    if (self.type == RequestENUMGet)
    {
        NSString *buffer = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.requestTextField.stringValue] encoding:NSUTF8StringEncoding error:nil];
        [self.textView setString:buffer];
    }else
    {
        [self requestPostSever:nil];
    }
}


- (void)requestPostSever:(NSDictionary *)dic
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{@"limit": @"10",@"token_access":@"9b8e309ee523bba3246ed433365c3861",@"token_login":@"edb80ffb6a05081cdf3bccec8430f10b",@"p":@"1"};
    [manager POST:self.requestTextField.stringValue parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", [responseObject JSONString]);
         [self.textView setString:[responseObject JSONString]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}




- (void)request:(Table_DS_Main *)main requestDic:(NSDictionary *)dic
{
    NSLog(@"---------------->%@<--------------",dic);
    if ([self.requestTextField.stringValue length] <= 0) {
		return;
	}
    
    if (self.type == RequestENUMGet)
    {
        [self requestGetSever];
    }else
    {
        [self requestPostSever:dic];
    }
    
}



- (void)requestGetSever
{
    
    NSString *buffer = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.requestTextField.stringValue] encoding:NSUTF8StringEncoding error:nil];
    [self.textView setString:buffer];
//    NSString *url = self.requestTextField.stringValue;
//    
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
}
@end
