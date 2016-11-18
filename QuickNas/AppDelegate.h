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
    NSString *resourcePath;
    ServerManager *serverMan;
    ServerManagerWindow *manWindow;
    int selectedMenuIndex;
    NSMutableDictionary *preferences;
    NSString *applicationSupportDirectory;
    int currentFrame;
    NSTimer *animTimer;
}
@property (strong) IBOutlet NSMenu *mainMenu;
@property (strong) IBOutlet NSMenuItem *serversMenu;
- (IBAction)showManageServersWindow:(id)sender;
- (IBAction)toggleOpenAtLogin:(id)sender;
@property (strong) IBOutlet NSMenuItem *openAtLoginMenuItem;
- (IBAction)connectAllServers:(id)sender;
@property (strong) IBOutlet NSMenuItem *connectAllServersMenu;

@end
