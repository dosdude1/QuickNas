//
//  AppDelegate.m
//  QuickNas
//
//  Created by Collin Mistr on 11/10/16.
//  Copyright (c) 2016 dosdude1 Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "GSStartup.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog([[NSBundle mainBundle]bundlePath]);
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"nas-16.png"]];
    [statusItem setMenu:self.mainMenu];
    [statusItem setHighlightMode:YES];
    [statusItem.image setTemplate:YES];
    serverMan=[[ServerManager alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    applicationSupportDirectory = [paths firstObject];
    if (![[NSFileManager defaultManager]fileExistsAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas"]])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([[NSFileManager defaultManager]fileExistsAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas/preferences.plist"]])
    {
        preferences = [[NSMutableDictionary alloc]initWithContentsOfFile:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas/preferences.plist"]];
    }
    else
    {
        preferences = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObject:[NSNumber numberWithBool:NO]] forKeys:[NSArray arrayWithObject:@"openAtLogin"]];
        [preferences writeToFile:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas/preferences.plist"] atomically:YES];
    }
    [self.openAtLoginMenuItem setState:[[preferences objectForKey:@"openAtLogin"]boolValue]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initMenu) name:@"didChangeSettings" object:nil];
    [self initMenu];
    for (int i=0; i<[serverMan getNumServers]; i++)
    {
        if ([[serverMan getServer:i]shouldConnectAtLaunch])
        {
            [[serverMan getServer:i]connect];
        }
    }
}
-(void)initMenu
{
    [[self.serversMenu submenu] removeAllItems];
    if ([serverMan getNumServers]>0)
    {
        for (int i=0; i<[serverMan getNumServers]; i++)
        {
            NSMenuItem *newMenuItem = [[NSMenuItem alloc]initWithTitle:[[serverMan getServer:i]getName] action:nil keyEquivalent:@""];
            NSMenu *menu = [[NSMenu alloc]init];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc]initWithTitle:[[serverMan getServer:i]getIP] action:nil keyEquivalent:@""];
            [menu addItem:actionMenuItem];
            [menu addItem:[NSMenuItem separatorItem]];
            actionMenuItem = [[NSMenuItem alloc]initWithTitle:@"Connect..." action:@selector(connectToServer:) keyEquivalent:@""];
            [actionMenuItem setRepresentedObject:[NSNumber numberWithInt:i]];
            [menu addItem:actionMenuItem];
            [menu addItem:[NSMenuItem separatorItem]];
            actionMenuItem = [[NSMenuItem alloc]initWithTitle:@"Edit Server Details..." action:@selector(editServer:) keyEquivalent:@""];
            [actionMenuItem setRepresentedObject:[NSNumber numberWithInt:i]];
            [menu addItem:actionMenuItem];
            actionMenuItem = [[NSMenuItem alloc]initWithTitle:@"Connect on App Launch" action:@selector(toggleConnectOnLaunch:) keyEquivalent:@""];
            [actionMenuItem setRepresentedObject:[NSNumber numberWithInt:i]];
            if ([[serverMan getServer:i]shouldConnectAtLaunch])
            {
                [actionMenuItem setState:NSOnState];
            }
            else
            {
                [actionMenuItem setState:NSOffState];
            }
            [menu addItem:actionMenuItem];
            [newMenuItem setSubmenu:menu];
            [[self.serversMenu submenu] insertItem:newMenuItem atIndex: [[[self.serversMenu submenu] itemArray] count]];
        }
    }
    else
    {
        NSMenuItem *newMenuItem = [[NSMenuItem alloc]initWithTitle:@"No Servers Added." action:nil keyEquivalent:@""];
        [[self.serversMenu submenu] insertItem:newMenuItem atIndex: [[[self.serversMenu submenu] itemArray] count]];
    }
}
-(void)connectToServer:(id)sender
{
    int selectedIndex=(int)[[sender representedObject]integerValue];
    [[serverMan getServer:selectedIndex] connect];
}
-(void)editServer:(id)sender
{
    [self showManageServersWindow:self];
    [manWindow openEditingForServerIndex:(int)[[sender representedObject]integerValue]];
}
-(void)toggleConnectOnLaunch:(id)sender
{
    int selectedIndex=(int)[[sender representedObject]integerValue];
    BOOL shouldConnect=NO;
    if ([[serverMan getServer:selectedIndex]shouldConnectAtLaunch])
    {
        shouldConnect=NO;
    }
    else
    {
        shouldConnect=YES;
    }
    [serverMan setServer:selectedIndex withName:[[serverMan getServer:selectedIndex]getName] ofType:[[serverMan getServer:selectedIndex]getType] withIP:[[serverMan getServer:selectedIndex]getIP] withPort:[[serverMan getServer:selectedIndex]getPort] withUsername:[[serverMan getServer:selectedIndex]getUsername] withPassword:[[serverMan getServer:selectedIndex]getPassword] connectAtLaunch:shouldConnect atMountPoint:[[serverMan getServer:selectedIndex]getMountPoint] inWorkgroup:[[serverMan getServer:selectedIndex]getWorkgroup]];
    [self initMenu];
}
-(IBAction)showAboutWindow:(id)sender
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:self];
}
- (IBAction)showManageServersWindow:(id)sender
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    if (!manWindow)
    {
        manWindow = [[ServerManagerWindow alloc]initWithWindowNibName:@"ServerManagerWindow"];
        [manWindow getServerData:serverMan];
    }
    [manWindow showWindow:self];
    [manWindow.mainWindow makeKeyAndOrderFront:self];
}

- (IBAction)toggleOpenAtLogin:(id)sender
{
    if ([[preferences objectForKey:@"openAtLogin"]boolValue])
    {
        [GSStartup loadAtStartup:NO];
        [self.openAtLoginMenuItem setState:NSOffState];
        [preferences setObject:[NSNumber numberWithBool:NO] forKey:@"openAtLogin"];
    }
    else
    {
        [GSStartup loadAtStartup:YES];
        [self.openAtLoginMenuItem setState:NSOnState];
        [preferences setObject:[NSNumber numberWithBool:YES] forKey:@"openAtLogin"];
    }
    [preferences writeToFile:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas/preferences.plist"] atomically:YES];
}

@end
