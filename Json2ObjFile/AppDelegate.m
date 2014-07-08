//
//  AppDelegate.m
//  Json2ObjFile
//
//  Created by zz on 14-6-23.
//  Copyright (c) 2014年 YunFeng. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONKit.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application

	[self.textClass setStringValue:@"DSInfoManager"];
	[self.textView setString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
}

- (NSString *)parse:(NSDictionary *)dictionary className:(NSString *)classname {
	NSArray *keyArray = [dictionary allKeys];

	NSString *fileStr = [NSString stringWithFormat:@"@interface %@ : NSObject \r\n\r\n", classname];

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

	[self.outputTextView setString:[NSString stringWithFormat:@"%@\r\n\r\n\r\n%@", self.outputTextView.string, fileStr]];
	return fileStr;
}

- (IBAction)touchCreateFile:(id)sender {
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
	NSString *buffer = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.requestTextField.stringValue] encoding:NSUTF8StringEncoding error:nil];
	[self.textView setString:buffer];
}

@end
