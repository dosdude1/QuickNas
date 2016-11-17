//
//  AppDelegate.h
//  QuickNas
//
//  Created by Collin Mistr on 11/10/16.
//  Copyright (c) 2016 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerManager.h"
#import "ServerManagerWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSStatusItem *statusItem;
    ServerManager *serverMan;
    ServerManagerWindow *manWindow;
    int selectedMenuIndex;
    NSMutableDictionary *preferences;
    NSString *applicationSupportDirectory;
}
@property (strong) IBOutlet NSMenu *mainMenu;
@property (strong) IBOutlet NSMenuItem *serversMenu;
- (IBAction)showManageServersWindow:(id)sender;
- (IBAction)toggleOpenAtLogin:(id)sender;
@property (strong) IBOutlet NSMenuItem *openAtLoginMenuItem;

@end
