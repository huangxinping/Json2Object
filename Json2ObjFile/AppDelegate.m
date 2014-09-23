//
//  AppDelegate.m
//  Json2ObjFile
//
//  Created by zz on 14-6-23.
//  Copyright (c) 2014年 YunFeng. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONKit.h"
#import "AFHTTPSessionManager.h"

@interface AppDelegate ();

@end

@implementation AppDelegate

- (id)init
{
	if ((self = [super init]))
    {
	}
	return self;
}

- (IBAction)valueChanged:(id)sender
{
    if(self.payloadCheckbox.state == 0)
    {
        [self.payloadScrollView setHidden:YES];
        [self.tabScrollView setHidden:NO];
    }
    else
    {
        [self.payloadScrollView setHidden:NO];
        [self.tabScrollView setHidden:YES];
    }
}

- (IBAction)touchParamsType:(id)sender
{
    NSPopUpButton *btn = (NSPopUpButton *)sender;
    self.mainController.paramsType = btn.indexOfSelectedItem;
}

- (IBAction)touchRequestType:(id)sender
{
	self.requestType = self.requesetType.indexOfSelectedItem;
    if (self.requestType == RequestENUMGet)
    {
        self.payloadCheckbox.state = 0;
        [self.payloadCheckbox setEnabled:NO];
        [self.payloadScrollView setHidden:YES];
        [self.tabScrollView setHidden:NO];
    }
    else
    {
        [self.payloadCheckbox setEnabled:YES];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	self.mainController.mainDeletate = self;
	[self createInitfile];
	self.requestType = RequestENUMGet;
	[self.textClass setStringValue:@"DSInfoManager"];
	[self.textView setString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
    
	[self.exportPath setStringValue:[self localDocumentsDirectory]];
}

- (void)createInitfile
{
	if (!fileManager)
    {
		fileManager = [NSFileManager defaultManager];
	}
}

- (NSString *)localDocumentsDirectory
{
	if (![self.exportPath.stringValue isEqualToString:@""])
    {
		return [self.exportPath stringValue];
	}
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *localPath = [NSString stringWithFormat:@"%@/JSONExport", documentsDirectory];
    
    
	NSError *error;
    
	if ([fileManager fileExistsAtPath:localPath])
    {
        //        NSLog(@"已经存在");
	}
	else
    {
		[fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
	}
    
	return localPath;
}

- (NSString *)parse:(NSDictionary *)dictionary className:(NSString *)classname
{
	NSArray *keyArray = [dictionary allKeys];
	NSString *fileStr = [NSString stringWithFormat:@"\r\n\r\n@interface %@ : NSObject \r\n\r\n", classname];
    
	for (int i = 0; i < keyArray.count; i++)
    {
		NSString *key = [keyArray objectAtIndex:i];
		id value = [dictionary objectForKey:key];
		if ([value isKindOfClass:[NSString class]])
        {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSString *%@;\r\n", fileStr, key];
		}
		else if ([value isKindOfClass:[NSNumber class]])
        {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSNumber *%@;\r\n", fileStr, key];
		}
		else if ([value isKindOfClass:[NSArray class]])
        {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSArray *%@;\r\n", fileStr, key];
			if ([(NSArray *)value count] &&
			    [[(NSArray *)value objectAtIndex:0] isKindOfClass:[NSDictionary class]])
            {
				[self parse:[(NSArray *)value objectAtIndex : 0] className:[NSString stringWithFormat:@"DS%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]]];
			}
		}
		else if ([value isKindOfClass:[NSDictionary class]])
        {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSDictionary *%@;\r\n", fileStr, key];
			[self parse:value className:[NSString stringWithFormat:@"DS%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]]];
		}
		else if ([value isKindOfClass:[NSNull class]])
        {
			fileStr = [NSString stringWithFormat:@"%@@property (nonatomic,strong) NSNull *%@;\r\n", fileStr, key];
		}
	}
    
	fileStr = [fileStr stringByAppendingString:@"\r\n@end"];
    
	NSString *head = [NSString stringWithFormat:@"\r\n#import <Foundation/Foundation.h>"];
    
	fileStr = [head stringByAppendingString:fileStr];
	NSError *error;
	NSString *filePath = [NSString stringWithFormat:@"%@.h", classname];
    
	NSString *filePath2 = [[self localDocumentsDirectory] stringByAppendingPathComponent:filePath];
	if ([fileStr writeToFile:filePath2 atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
		//      NSLog(@"************%@",[fileManager contentsOfDirectoryAtPath:localPath error:&error]);
		//        NSLog(@"创建成功");
	}
	else
    {
		NSLog(@"************%@", error);
	}
    
	NSString *classhead = [NSString stringWithFormat:@"\r#import \"%@\"\r", filePath];
    
	fileStr = [NSString stringWithFormat:@"%@\r%@", fileStr, classhead];
	fileStr = [NSString stringWithFormat:@"%@\r\n\r\n@implementation %@\r\n", fileStr, classname];
	fileStr = [NSString stringWithFormat:@"%@\r\n- (id)init {", fileStr];
	fileStr = [NSString stringWithFormat:@"%@\r\n    if ((self = [super init])) {", fileStr];
	fileStr = [NSString stringWithFormat:@"%@\r\n   }", fileStr];
	fileStr = [NSString stringWithFormat:@"%@\r\n   return self;", fileStr];
	fileStr = [NSString stringWithFormat:@"%@\r\n}\r\n", fileStr];
    
	fileStr = [fileStr stringByAppendingString:@"\r\n@end"];
    
	NSString *classfileStr = [NSString stringWithFormat:@"\r\n\r\n@implementation %@\r\n", classname];
	classfileStr = [NSString stringWithFormat:@"%@\r\n- (id)init {", classfileStr];
	classfileStr = [NSString stringWithFormat:@"%@\r\n    if ((self = [super init])) {", classfileStr];
	classfileStr = [NSString stringWithFormat:@"%@\r\n   }", classfileStr];
	classfileStr = [NSString stringWithFormat:@"%@\r\n   return self;", classfileStr];
	classfileStr = [NSString stringWithFormat:@"%@\r\n}\r\n", classfileStr];
	classfileStr = [NSString stringWithFormat:@"%@\r\n\r@end", classfileStr];
    
    
	NSString *classfilePath = [NSString stringWithFormat:@"%@.m", classname];
    
	classfileStr = [classhead stringByAppendingString:classfileStr];
    
	NSString *classfilePath2 = [[self localDocumentsDirectory] stringByAppendingPathComponent:classfilePath];
    
    
	if ([classfileStr writeToFile:classfilePath2 atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
		//        NSLog(@"************%@",[fileManager contentsOfDirectoryAtPath:[self localDocumentsDirectory] error:&error]);
	}
	else {
		NSLog(@"************%@", error);
	}
	[self.outputTextView setString:[NSString stringWithFormat:@"%@%@", self.outputTextView.string, fileStr]];
	return fileStr;
}

- (IBAction)touchCreateFile:(id)sender
{
	if ([_textView.string isEqualToString:@""])
    {
		NSAlert *alert = [NSAlert alertWithError:[NSError errorWithDomain:@"暂未解析JSON"
                                                                     code:404
                                                                 userInfo:@{
                                                                            @"reason":@"暂未解析JSON"
                                                                            }]
                          ];
		[alert runModal];
		return;
	}
	NSError *error;
	NSArray *files = [fileManager contentsOfDirectoryAtPath:[self localDocumentsDirectory] error:&error];
	for (NSString *file in files)
    {
		[fileManager removeItemAtPath:[[self localDocumentsDirectory] stringByAppendingString:file] error:&error];
	}
	NSString *jsonStr = self.textView.textStorage.string;
    
    if ([[jsonStr objectFromJSONString] isKindOfClass:[NSArray class]])
    {
        NSLog(@"这是一个数组");
        
        NSDictionary *listDic = @{@"list": [jsonStr objectFromJSONString]};
        [self.outputTextView setString:@""];
        [self parse:listDic className:self.textClass.stringValue];
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"解析结果" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"完成"];
        [alert runModal];
        return;
    }

	NSDictionary *dic = [self GetDictionaryWithJson:jsonStr];
	if (dic == nil)
    {
		//		self.textView.string = @"JSON格式错误";
		NSAlert *alert = [NSAlert alertWithError:[NSError errorWithDomain:@"JSON格式错误" code:500 userInfo:nil]];
		[alert runModal];
		return;
	}
    
    [self.outputTextView setString:@""];
    [self parse:dic className:self.textClass.stringValue];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"解析结果" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:@"完成"];
    [alert runModal];
}

- (NSDictionary *)GetDictionaryWithJson:(NSString *)jsonStr
{
	return [jsonStr objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
}

- (void)requestPostWithHeadDic:(NSDictionary *)headDic bodyDic:(NSDictionary *)bodyDic
{
    if (self.payloadCheckbox.state == 1)
    {
        bodyDic = nil;
        bodyDic = [self.payloadTextView.string objectFromJSONString];
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:headDic];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:self.requestTextField.stringValue] sessionConfiguration:config];
    if (self.payloadCheckbox.state == 1)
    {
        manager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
    }
    manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    __weak typeof(self) weakSelf = self;
    [manager POST:self.requestTextField.stringValue parameters:bodyDic success:^(NSURLSessionDataTask *task, id responseObject) {
        [weakSelf parse:responseObject className:weakSelf.textClass.stringValue];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)request:(Table_DS_Main *)main requestWithHeadDic:(NSDictionary *)headDic bodyDic:(NSDictionary *)bodyDic
{
	if ([self.requestTextField.stringValue length] <= 0)
    {
		return;
	}
    
	if (self.requestType == RequestENUMGet)
    {
		[self requestGetWithHeadDic:headDic bodyDic:bodyDic];
	}
	else
    {
		[self requestPostWithHeadDic:headDic bodyDic:bodyDic];
	}
}

- (void)requestGetWithHeadDic:(NSDictionary *)headDic bodyDic:(NSDictionary *)bodyDic
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:headDic];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:self.requestTextField.stringValue] sessionConfiguration:config];
    manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    __weak typeof(self) weakSelf = self;
    [manager GET:self.requestTextField.stringValue parameters:bodyDic success:^(NSURLSessionDataTask *task, id responseObject) {
        [weakSelf parse:responseObject className:weakSelf.textClass.stringValue];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (IBAction)exportButtonClicked:(id)sender
{
	NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    
	// Enable the selection of files in the dialog.
	[openDlg setCanChooseFiles:NO];
    
	// Enable the selection of directories in the dialog.
	[openDlg setCanChooseDirectories:YES];
    
	// Change "Open" dialog button to "Select"
	[openDlg setPrompt:@"Select"];
    
	// Display the dialog.  If the OK button was pressed,
	// process the files.
	if ([openDlg runModal] == NSOKButton)
    {
		// Get an array containing the full filenames of all
		// files and directories selected.
		NSArray *files = [openDlg URLs];
		// Loop through all the files and process them.
		for (int i = 0; i < [files count]; i++)
        {
			NSURL *fileName = [files objectAtIndex:i];
			[self.exportPath setStringValue:[fileName path]];
			break;
			// Do something with the filename.
		}
	}
}

@end
