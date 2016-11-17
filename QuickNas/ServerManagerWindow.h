//
//  ServerManagerWindow.h
//  QuickNas
//
//  Created by Collin Mistr on 11/10/16.
//  Copyright (c) 2016 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerManager.h"

@interface ServerManagerWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
    ServerManager *serverMan;
    NSMutableArray *tableData;
    BOOL didSelectRow;
    NSInteger clickedRow;
    NSString *applicationSupportDirectory;
    NSArray *serverTypes;
}

@property (strong) IBOutlet NSWindow *mainWindow;

@property (strong) IBOutlet NSTableView *serverTable;
-(void)getServerData:(ServerManager *)inMan;
- (IBAction)addNewServer:(id)sender;
@property (strong) IBOutlet NSPanel *serverEntryWindow;
- (IBAction)closeSheet:(id)sender;
@property (strong) IBOutlet NSTextField *serverNameField;
@property (strong) IBOutlet NSTextField *serverIPField;
@property (strong) IBOutlet NSTextField *portField;
@property (strong) IBOutlet NSTextField *userNameField;
@property (strong) IBOutlet NSSecureTextField *passwordField;
@property (strong) IBOutlet NSButton *connectOnLaunchBox;
- (IBAction)saveSettings:(id)sender;
- (IBAction)removeServer:(id)sender;
-(void)openEditingForServerIndex:(int)index;
@property (strong) IBOutlet NSPopUpButton *serverTypeList;
@property (strong) IBOutlet NSTextField *mountPointField;
@property (strong) IBOutlet NSTextField *workgroupField;

@end
