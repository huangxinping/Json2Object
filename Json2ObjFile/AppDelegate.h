//
//  AppDelegate.h
//  Json2ObjFile
//
//  Created by zz on 14-6-23.
//  Copyright (c) 2014年 YunFeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Table_DS_Main.h"

typedef NS_ENUM (NSInteger, RequestEnum){
	RequestENUMGet = 0, //GET
	RequestENUMPOST, //Post
};

@interface AppDelegate : NSObject <NSApplicationDelegate, SelectMainDelegate>
{
	NSFileManager *fileManager;
}

@property (assign) IBOutlet NSWindow *window;


- (IBAction)touchCreateFile:(id)sender;
@property (weak) IBOutlet NSTextField *textClass;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@property (weak) IBOutlet NSTextField *requestTextField;

@property (weak) IBOutlet NSPopUpButton *requesetType;
- (IBAction)touchRequestType:(id)sender;
@property (nonatomic, assign) RequestEnum requestType;
@property (weak) IBOutlet NSTextFieldCell *exportPath;
@property (weak) IBOutlet NSButton *exportButton;


@property (weak) IBOutlet NSButton *payloadCheckbox;

@property (weak) IBOutlet NSScrollView *payloadScrollView;
@property (unsafe_unretained) IBOutlet NSTextView *payloadTextView;


@property (weak) IBOutlet NSScrollView *tabScrollView;
@property (weak) IBOutlet NSTableView *postTab;
@property (nonatomic, weak) IBOutlet Table_DS_Main *mainController;
@end
